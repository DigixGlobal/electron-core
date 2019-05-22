# frozen_string_literal: true

module Accounts
  class RequestAuthorization
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    step :find_by_credentials
    map :generate_token

    private

    def find_by_credentials(email: '', password: '')
      unless (user = User.find_by(email: email)) && user.valid_password?(password)
        return M.Failure(type: :invalid_credentials)
      end

      return M.Failure(type: :user_unconfirmed) unless user.confirmed?

      M.Success(user)
    end

    def generate_token(user)
      user.create_new_auth_token
    end
  end
end
