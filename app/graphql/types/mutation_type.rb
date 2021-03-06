# frozen_string_literal: true

module Types
  class MutationType < Types::Base::BaseObject
    field :register_user, mutation: Mutations::RegisterUserMutation
    field :sign_in, mutation: Mutations::SignInMutation
    field :request_password_reset, mutation: Mutations::RequestPasswordResetMutation
    field :reset_password, mutation: Mutations::ResetPasswordMutation

    field :draft_tier2_kyc, mutation: Mutations::DraftTier2KycMutation
    field :approve_applying_kyc, mutation: Mutations::ApproveApplyingKycMutation
    field :reject_applying_kyc, mutation: Mutations::RejectApplyingKycMutation

    field :request_change_eth_address, mutation: Mutations::RequestChangeEthAddressMutation

    field :sign_pricefeed, mutation: Mutations::SignPricefeedMutation
  end
end
