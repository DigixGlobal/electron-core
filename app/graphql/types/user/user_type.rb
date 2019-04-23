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
      field :tnc_version, String,
            null: false,
            description: 'The terms and condition version which this user accepted.'
      field :kyc, Types::Kyc::KycType,
            null: false,
            description: 'User KYC information'

      def kyc
        KycService.find_by_user(object.id)
      end

      def self.authorized?(object, context)
        super && context.fetch(:current_user, nil)
      end
    end
  end
end
