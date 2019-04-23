# frozen_string_literal: true

module Types
  module Kyc
    class KycApplyingType < Types::Base::BaseUnion
      description 'A KYC application that may be submitted and approved.'
      possible_types Types::Kyc::KycTier2Type

      def self.resolve_type(object, _context)
        case object
        when KycTypes::Tier2KycEntity then
          Types::Kyc::KycTier2Type
        end
      end
    end
  end
end
