# frozen_string_literal: true

module Accounts
  class RegisterUser
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    around :transaction, with: 'transaction'

    step :validate
    step :save
    step :register_kyc
    step :send_confirmation
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:email)
          .filled(:str?, :email?, max_size?: 254)
        required(:password)
          .filled(:str?, min_size?: 6, max_size?: 128)
        required(:tnc_version)
          .filled(:str?, max_size?: 50)
      end
    end

    def validate(attrs)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad
    end

    def save(params)
      attrs = AppSchema.preprocess_spaces(params.slice(*schema.rules.keys))

      user = User.new(attrs)

      return M.Failure(type: :invalid_data, errors: user.errors) unless user.save

      M.Success(user: user, params: params)
    end

    def register_kyc(user:, params:)
      result = KycService.register_kyc(user.id, params)

      return result if result.failure?

      M.Success(user)
    end

    def send_confirmation(user)
      user.send_confirmation_instructions

      M.Success(user)
    rescue StandardError
      M.Failure(type: :email_not_sent)
    end

    def as_entity(user)
      AccountTypes::UserEntity.from_model(user)
    end
  end
end
