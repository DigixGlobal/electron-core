# frozen_string_literal: true

module Types
  module Kyc
    class KycTier2Type < Types::Base::BaseObject
      description 'A tier two KYC application.'

      field :id, ID,
            null: false,
            description: 'Type ID'
      field :status, Types::Kyc::KycStatusEnum,
            null: false,
            description: 'Current status of the KYC request'
      field :form_step, Types::Scalar::PositiveInteger,
            null: true,
            description: <<~EOS
              An integer indicating the current step of the wizard of process.
            EOS

      field :identification_proof_number, String,
            null: true,
            description: 'Number of the identification proof'
      field :identification_proof_type, Types::Kyc::KycIdentificationProofTypeEnum,
            null: true,
            description: 'Type of the identification_proof'
      field :identification_proof_expiration_date, Types::Scalar::Date,
            null: true,
            description: 'Expiration date of the identification proof'
      field :identification_proof_image, Types::Kyc::KycImageType,
            null: true,
            description: 'Image of the identification proof'
      field :residence_line_1, String,
            null: true,
            description: 'Line 1 address of residence'
      field :residence_line_2, String,
            null: true,
            description: 'Line 2 address of residence'
      field :residence_city, String,
            null: true,
            description: 'City of residence'
      field :residence_postal_code, String,
            null: true,
            description: 'Postal code of residence'
      field :residence_proof_type, Types::Kyc::KycResidenceProofTypeEnum,
            null: true,
            description: 'Type of residence proof'
      field :residence_proof_image, Types::Kyc::KycImageType,
            null: true,
            description: 'Image of residence proof'
      field :identification_pose_image, Types::Kyc::KycImageType,
            null: true,
            description: 'Image of identification pose'

      field :created_at, GraphQL::Types::ISO8601DateTime,
            null: false,
            description: 'Date when the KYC was submitted'
      field :updated_at, GraphQL::Types::ISO8601DateTime,
            null: false,
            description: 'Date when the KYC was last updated'
    end
  end
end
