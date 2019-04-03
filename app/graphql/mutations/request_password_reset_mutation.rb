# frozen_string_literal: true

module Mutations
  class RequestPasswordResetMutation < Types::Base::BaseMutation
    description <<~EOS
      Request a password reset via email.

      Once requested, an email is sent to the address for the reset password link.
    EOS

    argument :email, String,
             required: true,
             description: "User's email"

    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - Email does not exist
          EOS

    KEY = :user

    def resolve(email:)
      AccountService.request_password_reset(email).match do
        success do
          model_result(KEY, nil)
        end

        failure(:user_not_found) do
          form_error(KEY, 'User not found')
        end
      end
    end
  end
end
