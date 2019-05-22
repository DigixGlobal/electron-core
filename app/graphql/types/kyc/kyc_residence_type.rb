# frozen_string_literal: true

module Types
  module Kyc
    class KycResidenceType < Types::Base::BaseObject
      description "A KYC's residence information."

      field :country, Types::Value::CountryValue,
            null: true,
            description: 'Country of residence'
    end
  end
end
