# frozen_string_literal: true

module Mutations
  class ResetPasswordMutation < Types::Base::BaseMutation
    description <<~EOS
      Given a password reset token, change the user password to a new one.

      Once the token is used, it cannot be used again.
    EOS

    argument :token, String,
             required: true,
             description: <<~EOS
               The password reset token sent via email.

               Validations:
               - Must be valid
             EOS
    argument :password, String,
             required: true,
             description: <<~EOS
               User's new password.

               Validations:
               - Maximum of 254 characters
               - Must contain a lowercase letter, an uppercase letter and a digit
             EOS
    argument :password_confirmation, String,
             required: true,
             description: <<~EOS
               User's password confirmation.

               Validations:
               - Must match password
             EOS

    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - Email does not exist
          EOS

    KEY = :user

    def resolve(**attrs)
      AccountService.reset_password(attrs).match do
        success do
          model_result(KEY, nil)
        end

        failure(:invalid_data) do |result|
          model_errors(KEY, result[:errors])
        end
      end
    end
  end
end
