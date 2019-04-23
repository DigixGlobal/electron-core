# frozen_string_literal: true

require 'dry/monads/maybe'

module Kycs
  class SubmitApplyingKyc
    include Dry::Transaction

    M = Dry::Monads

    step :check
    step :submit

    private

    def check(user_id)
      unless (user = AccountService.find(user_id)) &&
             Ability.new(user).can?(:submit, KycTypes::KycEntity)
        return M.Failure(type: :unauthorized_action)
      end

      M.Success(KycService.find_by_user(user_id))
    end

    def submit(kyc)
      model = kyc.to_model

      model.update_attribute(:applying_status, :pending)

      M.Success(KycTypes::Tier2KycEntity.from_model(model))
    end
  end
end
