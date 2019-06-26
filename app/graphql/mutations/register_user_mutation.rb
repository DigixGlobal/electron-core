# frozen_string_literal: true

module Mutations
  class RegisterUserMutation < Types::Base::BaseMutation
    description <<~EOS
      Register user.

      Once registered, an email is sent to the user's address for the confirmation link.
    EOS

    argument :first_name, String,
             required: true,
             description: <<~EOS
               First name of the user.

               Validations:
               - Maximum of 150 characters
             EOS
    argument :last_name, String,
             required: true,
             description: <<~EOS
               Last name of the user.

               Validations:
               - Maximum of 150 characters
             EOS
    argument :birthdate, Types::Scalar::Date,
             required: true,
             description: <<~EOS
               Birth date of the user.

               Validations:
               - Must be 18 years or older
             EOS
    argument :country_of_residence, Types::Value::LegalCountryValue,
             required: true,
             description: <<~EOS
               Country of the user's country of residence.

               Validations: None
             EOS
    argument :citizenship, Types::Value::LegalCountryValue,
             required: true,
             description: <<~EOS
               Country of the user's citizenship.

               Validations: None
             EOS
    argument :tnc_version, String,
             required: true,
             description: <<~EOS
               Terms and conditions accepted by the user.

               Validations: None
             EOS
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
               - Minimum of 6 characters
               - Maximum of 128 characters
             EOS

    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors.

            Operation Errors:
            - Email is already used
          EOS

    KEY = :user

    def resolve(attrs)
      result = AccountService.register_user(attrs)

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |_user| model_result(KEY, nil) }
        m.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
        m.failure(:email_not_sent) { |_| form_error(KEY, 'Email not sent') }
      end
    end
  end
end
