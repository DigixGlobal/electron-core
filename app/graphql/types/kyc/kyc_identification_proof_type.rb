# frozen_string_literal: true

module Types
  module Kyc
    class KycIdentificationProofType < Types::Base::BaseObject
      description 'Identification proof for KYC'

      field :number, String,
            null: false,
            description: 'Designated code/number for the ID'
      field :type, Types::Kyc::KycIdentificationProofTypeEnum,
            null: false,
            description: 'Type of ID used'
      field :expiration_date, Types::Scalar::Date,
            null: false,
            description: 'Expiration date of the ID'
      field :image, Types::Kyc::KycImageType,
            null: true,
            description: <<~EOS
              Image of the ID.

              It is possible for this to be `null` after submitting
               since file storage is asynchronous, so be careful with the mutation.
               However, it should be a valid object in practice.
            EOS
      field :back_image, Types::Kyc::KycImageType,
            null: true,
            description: <<~EOS
              An additional image of the ID usually the back.
               This is used for the backside of the passport.

              It is possible for this to be `null` after submitting
               since file storage is asynchronous, so be careful with the mutation.
               However, it should be a valid object in practice.
            EOS
    end
  end
end
