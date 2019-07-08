# frozen_string_literal: true

module Accounts
  class ResetPassword
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    step :validate
    step :reset_password
    tee :send_password_changed
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        configure do
          def self.messages
            super.merge(en: { errors: {
                          token?: 'is not a valid token'
                        } })
          end

          def token?(value)
            User.with_reset_password_token(value) ? true : false
          end
        end

        required(:token)
          .filled(:str?, :token?)
        required(:password)
          .filled(:str?, min_size?: 6, max_size?: 128)
          .confirmation
      end
    end

    def validate(attrs)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad
    end

    def reset_password(params)
      attrs = AppSchema.preprocess_spaces(params.slice(*schema.rules.keys))

      user = User.with_reset_password_token(attrs[:token])
      user.reset_password(
        attrs[:password],
        attrs[:password_confirmation]
      )

      M.Success(user)
    end

    def send_password_changed(user)
      user.send_password_change_notification
    rescue StandardError
      nil
    end

    def as_entity(user)
      AccountTypes::UserEntity.from_model(user)
    end
  end
end
