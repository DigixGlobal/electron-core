# frozen_string_literal: true

module Types
  module Kyc
    class KycResidenceProofType < Types::Base::BaseObject
      description 'Residence proof for KYC'

      field :image, Types::Kyc::KycImageType,
            null: true,
            description: <<~EOS
              Image of the residence proof.
               It is possible for this to be `null` after submitting
               since file storage is asynchronous, so be careful with the mutation.
               However, it should be a valid object in practice.
            EOS
      end
  end
end
