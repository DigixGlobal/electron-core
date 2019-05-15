# frozen_string_literal: true

module Mutations
  class SubmitApplyingKycMutation < Types::Base::BaseMutation
    description <<~EOS
      As the current user with an drafted applying KYC,
       submit the KYC for review from an KYC officer.

      Also, the user must have set an eth address to submit.
    EOS

    field :applying_kyc, Types::Kyc::KycApplyingType,
          null: true,
          description: 'Submitted applying KYC'
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - No drafted applying KYC
            - Eth address not yet set
          EOS

    KEY = :applying_kyc

    def resolve
      user = context.fetch(:current_user)

      result = KycService.submit_applying_user_kyc(user.id)

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |kyc| model_result(KEY, kyc) }
        m.failure(:unauthorized_action) { |_| form_error(KEY, 'No drafted applying KYC') }
      end
    end

    def self.authorized?(object, context)
      super && context.fetch(:current_user, nil)
    end
  end
end
