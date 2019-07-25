# frozen_string_literal: true

module Types
  module Kyc
    class KycIdentificationProofTypeEnum < Types::Base::BaseEnum
      description 'ID proof type'

      value 'PASSPORT', 'International passport',
            value: 'passport'
      value 'IDENTITY_CARD', 'National Identity Card (Drivers License not accepted)',
            value: 'identity_card'
    end
  end
end
