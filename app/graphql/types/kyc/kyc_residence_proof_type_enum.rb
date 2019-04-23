# frozen_string_literal: true

module Types
  module Kyc
    class KycResidenceProofTypeEnum < Types::Base::BaseEnum
      description 'Type of residence proof for KYC'

      value 'UTILITY_BILL', 'Utility bill such as electricity or water',
            value: 'utility_bill'
      value 'BANK_STATEMENT', 'Bank statement',
            value: 'bank_statement'
    end
  end
end
