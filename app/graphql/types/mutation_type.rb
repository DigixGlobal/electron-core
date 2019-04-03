# frozen_string_literal: true

module Types
  class MutationType < Types::Base::BaseObject
    field :register_user, mutation: Mutations::RegisterUserMutation
    field :sign_in, mutation: Mutations::SignInMutation
    field :request_password_reset, mutation: Mutations::RequestPasswordResetMutation
  end
end
