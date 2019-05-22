# frozen_string_literal: true

module Types
  module User
    class EthAddressChangeStatusEnum < Types::Base::BaseEnum
      description 'Eth change status enum'

      value 'PENDING', 'Change is still being checked',
            value: 'pending'
      value 'UPDATED', 'Change is completed',
            value: 'updated'
    end
  end
end
