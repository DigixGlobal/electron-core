# frozen_string_literal: true

module Types
  module User
    class EthAddressChangeType < Types::Base::BaseObject
      description "Changes in an user's Eth address"

      field :eth_address, String,
            null: false,
            description: 'New value of the Eth address'
    end
  end
end
