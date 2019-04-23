# frozen_string_literal: true

module Types
  module Kyc
    class KycTierEnum < Types::Base::BaseEnum
      description 'KYC tier'

      value 'TIER_1', 'KYC is at the most basic level of usage',
            value: 'tier_1'
      value 'TIER_2', 'KYC is at the next level of usage',
            value: 'tier_2'
    end
  end
end
