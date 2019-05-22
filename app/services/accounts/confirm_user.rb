# frozen_string_literal: true

module Accounts
  class ConfirmUser
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    step :confirm_by_token
    map :as_entity

    private

    def confirm_by_token(token)
      user = User.confirm_by_token(token)

      return M.Failure(type: :user_not_found) unless user.errors[:confirmation_token].blank?
      return M.Failure(type: :user_already_confirmed) unless user.errors[:email].blank?

      M.Success(user)
    end

    def as_entity(user)
      AccountTypes::UserEntity.from_model(user)
    end
  end
end
