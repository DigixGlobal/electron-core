# frozen_string_literal: true

module Types
  class ValidationType < Types::Base::BaseObject
    description 'An object to hold validations from mutations to allow inline validation.'

    field :is_user_email_available, Boolean,
          null: false do
      argument :email, String,
               required: true
      description <<~EOS
        Given an email, check if it the email can be used in registration.
      EOS
    end

    def is_user_email_available(email:)
      AccountService.find_by_email(email).blank?
    end
  end
end
