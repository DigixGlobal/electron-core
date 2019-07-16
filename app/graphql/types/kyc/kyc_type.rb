# frozen_string_literal: true

module Types
  module Kyc
    class KycType < Types::Base::BaseObject
      description "An user's KYC information."

      field :id, ID,
            null: false,
            description: 'Type ID'
      field :tier, Types::Kyc::KycTierEnum,
            null: false,
            description: 'Current tier of the KYC'
      field :expiration_date, Types::Scalar::Date,
            null: true,
            description: <<~EOS
              Expiration date of the KYC.
               After this date, the KYC is marked `EXPIRED`
               and the user should submit again.
            EOS
      field :applying_kyc, Types::Kyc::KycApplyingType,
            null: true,
            description: <<~EOS
              If the user has drafted a KYC, this will be that KYC.
               Otherwise, this is just `null`
            EOS
      field :first_name, String,
            null: true,
            description: 'First name of the user'
      field :last_name, String,
            null: true,
            description: 'Last name of the user'
      field :birthdate, Types::Scalar::Date,
            null: true,
            description: 'Birthdate of the user'
      field :citizenship, Types::Value::CountryValue,
            null: true,
            description: 'Citizenship country of the user'

      field :residence, Types::Kyc::KycResidenceType,
            null: false,
            description: 'Residence of the user'

      field :identification_proof, Types::Kyc::KycIdentificationProofType,
            null: false,
            description: <<~EOS
              ID image such as passport or national ID of the user
            EOS
      field :residence_proof, Types::Kyc::KycResidenceProofType,
            null: false,
            description: <<~EOS
              Residential proof such as utility bills of the user
            EOS
      field :identification_pose, Types::Kyc::KycIdentificationPoseType,
            null: false,
            description: <<~EOS
              Pose image where the user is holding an ID
            EOS

      field :created_at, GraphQL::Types::ISO8601DateTime,
            null: false,
            description: 'Date when the KYC was submitted'
      field :updated_at, GraphQL::Types::ISO8601DateTime,
            null: false,
            description: 'Date when the KYC was last updated'

      def applying_kyc
        kyc = object.to_model

        return nil unless kyc.applying_status

        case kyc.tier
        when 'tier_1' then
          KycTypes::Tier2KycEntity.from_model(kyc)
        when 'tier_2' then
          nil
        end
      end
    end
  end
end
