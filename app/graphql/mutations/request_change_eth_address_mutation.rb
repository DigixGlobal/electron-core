# frozen_string_literal: true

require 'cancancan'

module Mutations
  class RequestChangeEthAddressMutation < Types::Base::BaseMutation
    description <<~EOS
      As the current user, request to change your eth address.
       This requires email confirmation to fully change the address.
    EOS

    argument :eth_address, String,
             required: true,
             description: <<~EOS
               New user's eth address.

               Validations:
               - Must be a valid eth addresss
               - Already in use
             EOS

    field :eth_address_change, Types::User::EthAddressChangeType,
          null: true,
          description: 'Change eth address process'
    field :errors, [UserErrorType],
          null: false,
          description: 'Mutation errors'

    KEY = :eth_address_change

    def resolve(eth_address:)
      user = context.fetch(:current_user)

      result = AccountService.request_change_eth_address(user.id, eth_address)

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |kyc| model_result(KEY, kyc) }
        m.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
        m.failure(:email_not_sent) { |_| form_error(KEY, 'Email not sent') }
        m.failure { |_| form_error(KEY, 'Error in changing address') }
      end
    end

    def self.authorized?(object, context)
      super &&
        (user = context.fetch(:current_user, nil)) &&
        Ability.new(user).can?(:change_eth_address, AccountTypes::UserEntity)
    end
  end
end
