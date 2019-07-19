# frozen_string_literal: true

module Types
  module User
    class UserType < Types::Base::BaseObject
      description 'DAO users who publish proposals and vote for them'

      field :id, ID,
            null: false,
            description: 'Type ID'
      field :email, String,
            null: false,
            description: "User's email"
      field :eth_address, Types::Scalar::EthAddress,
            null: true,
            description: "User's ethereum address"
      field :eth_address_change, Types::User::EthAddressChangeType,
            null: true,
            description: "User's ethereum address"
      field :tnc_version, String,
            null: false,
            description: 'The terms and condition version which this user accepted.'
      field :kyc, Types::Kyc::KycType,
            null: false,
            description: 'User KYC information'
      field :applying_kyc, Types::Kyc::KycApplyingType,
            null: true,
            description: <<~EOS
              If the user has drafted a KYC, this will be that KYC.
               Otherwise, this is just `null`
            EOS

      def kyc
        KycService.find_by_user(object.id)
      end

      def applying_kyc
        kyc = KycService.find_by_user(object.id).to_model

        return nil unless kyc.applying_status

        case kyc.tier
        when 'tier_1' then
          KycTypes::Tier2KycEntity.from_model(kyc)
        when 'tier_2' then
          nil
        end
      end

      def eth_address_change
        change = AccountTypes::EthAddressChangeEntity.from_model(context[:current_user])

        return nil unless change.eth_address

        change
      end

      def self.authorized?(object, context)
        super && context.fetch(:current_user, nil)
      end
    end
  end
end
