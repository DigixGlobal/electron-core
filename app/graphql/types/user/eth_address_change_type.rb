# frozen_string_literal: true

module Types
  module User
    class EthAddressChangeType < Types::Base::BaseObject
      description "Changes in an user's Eth addressx"

      field :eth_address, String,
            null: false,
            description: 'New value of the Eth address'
      field :status, Types::User::EthAddressChangeStatusEnum,
            null: false,
            description: 'Status of the change'
    end
  end
end
