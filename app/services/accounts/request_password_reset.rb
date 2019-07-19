# frozen_string_literal: true

module Accounts
  class RequestPasswordReset
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    step :find_by_email
    step :send_confirmation
    map :as_entity

    private

    def find_by_email(email)
      unless (user = User.find_by(email: email)) && user.confirmed?
        return M.Failure(type: :user_not_found)
      end

      M.Success(user)
    end

    def send_password_reset(user)
      user.send_reset_password_instructions

      M.Success(user)
    rescue StandardError
      M.Failure(type: :email_not_sent)
    end

    def as_entity(user)
      AccountTypes::UserEntity.from_model(user)
    end
  end
end
