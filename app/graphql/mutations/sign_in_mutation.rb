# frozen_string_literal: true

module Mutations
  class SignInMutation < Types::Base::BaseMutation
    description <<~EOS
      Sign in via email and password.
    EOS

    argument :email, String,
             required: true,
             description: "User's email"
    argument :password, String,
             required: true,
             description: <<~EOS
               User's new password.

               Validations:
               - Maximum of 254 characters
               - Must contain a lowercase letter, an uppercase letter and a digit
             EOS

    field :authorization, Types::User::AuthorizationType,
          null: true,
          description: "User's authorization"
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - User is not yet confirmed
            - Invalid email/password
          EOS

    KEY = :authorization

    def resolve(attrs)
      result = AccountService.request_authorization(attrs)

      AppMatcher.result_matcher.call(result) do |m|
        m.success do |token|
          model_result(KEY, token)
        end

        m.failure(:invalid_credentials) do |_|
          form_error(KEY, 'Invalid email and/or password')
        end

        m.failure(:user_unconfirmed) do |_|
          form_error(KEY, 'User unconfirmed.')
        end
      end
    end
  end
end
