# frozen_string_literal: true

require 'cancancan'

module Mutations
  class RejectApplyingKycMutation < Types::Base::BaseMutation
    description <<~EOS
      As a KYC officer, reject a pending KYC with a reason.

      Role: KYC Officer
    EOS

    argument :applying_kyc_id, ID,
             required: true,
             description: 'The ID of the KYC'
    argument :rejection_reason, Types::Value::RejectionReasonValue,
             required: true,
             description: 'Reason for rejecting the KYC'

    field :applying_kyc, Types::Kyc::KycApplyingType,
          null: true,
          description: 'Approved KYC'
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - KYC is not pending
            - KYC not found
          EOS

    KEY = :applying_kyc

    def resolve(applying_kyc_id:, rejection_reason:)
      officer = context.fetch(:current_user)

      result = KycService.reject_applying_kyc(
        officer.id,
        applying_kyc_id,
        rejection_reason: rejection_reason
      )

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |kyc| model_result(KEY, kyc) }
        m.failure(:kyc_not_found) { |_| model_errors(KEY, applying_kyc_id: 'does not exist') }
        m.failure(:kyc_not_pending) { |_| form_error(KEY, 'KYC not pending') }
        m.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
      end
    end

    def self.authorized?(object, context)
      super &&
        (user = context.fetch(:current_user, nil)) &&
        Ability.new(user).can?(:reject, KycTypes::Tier2KycEntity)
    end
  end
end
