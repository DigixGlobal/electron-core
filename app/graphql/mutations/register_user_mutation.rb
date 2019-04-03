# frozen_string_literal: true

module Mutations
  class RegisterUserMutation < Types::Base::BaseMutation
    description <<~EOS
      Register user.

      Once registered, an email is sent to the user's address for the confirmation link.
    EOS

    class UnconfrimedUserType < Types::Base::BaseObject
      description <<~EOS
        Electron user who signed up but hasn't confirmed yet.

        The user must confirm the email sent to his address to gain access to the system.
      EOS

      field :email, String,
            null: false,
            description: 'Email address of the user'
    end

    argument :email, String,
             required: true,
             description: <<~EOS
               User's email.

               Validations:
               - Maximum of 254 characters
               - Must be of this format: `<name_part>@<domain_part>`
             EOS
    argument :password, String,
             required: true,
             description: <<~EOS
               User's password.

               Validations:
               - Maximum of 254 characters
               - Must contain a lowercase letter, an uppercase letter and a digit
             EOS

    field :user, UnconfrimedUserType,
          null: true,
          description: 'Newly registered user'
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors.

            Operation Errors:
            - Email is already used
          EOS

    KEY = :user

    def resolve(email:, password:)
      AccountService.register_user(email: email, password: password).match do
        success do |result|
          model_result(KEY, result[:user])
        end

        failure(:invalid_data) do |result|
          model_errors(KEY, result[:errors])
        end
      end
    end
  end
end
