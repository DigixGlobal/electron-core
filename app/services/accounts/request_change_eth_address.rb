# frozen_string_literal: true

require 'cancancan'

module Accounts
  class RequestChangeEthAddress
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    around :transaction, with: 'transaction'

    step :find_by_id
    step :check
    step :validate
    step :change
    step :send_confirmation
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        configure do
          def self.messages
            super.merge(en: { errors: {
                          unique_eth_address?: 'is not a unique/different eth address'
                        } })
          end

          def unique_eth_address?(value)
            user = User.find_by(eth_address: value) || User.find_by(new_eth_address: value)

            user.blank?
          end
        end

        required(:eth_address)
          .filled(:str?, :eth_address?, :unique_eth_address?, size?: 42)
      end
    end

    def find_by_id(id:, **attrs)
      unless (user = AccountService.find(id))
        return M.Failure(type: :user_not_found)
      end

      M.Success(user: user, **attrs)
    end

    def check(user:, **attrs)
      unless Ability.new(user).can?(:change_eth_address, AccountTypes::UserEntity)
        return M.Failure(type: :unauthorized_action)
      end

      M.Success(user: user, **attrs)
    end

    def validate(eth_address:, user:)
      result = schema.call(eth_address: eth_address)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad
            .fmap { |params| { eth_address: params[:eth_address], user: user } }
    end

    def change(eth_address:, user:)
      model = user.to_model

      _raw, token = Devise.token_generator.generate(User, :change_eth_address_token)

      unless model.update_attributes(
        new_eth_address: eth_address,
        change_eth_address_token: token,
        change_eth_address_sent_at: Time.now.utc
      )
        return M.Failure(type: :invalid_data, errors: user.errors)
      end

      M.Success(user: model, token: token)
    end

    def send_confirmation(user:, token:)
      UserMailer.with(user: user, token: token).change_eth_address_confirmation.deliver_now

      M.Success(user)
    rescue StandardError
      M.Failure(type: :email_not_sent)
    end

    def as_entity(user)
      AccountTypes::EthAddressChangeEntity.from_model(user)
    end
  end
end
