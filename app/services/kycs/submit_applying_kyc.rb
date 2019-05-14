# frozen_string_literal: true

require 'dry/monads/maybe'

module Kycs
  class SubmitApplyingKyc
    include Dry::Transaction

    M = Dry::Monads

    step :find_by_user_id
    step :check
    step :submit
    map :as_entity

    private

    def find_by_user_id(user_id)
      unless (user = AccountService.find(user_id))
        return M.Failure(type: :user_not_found)
      end

      M.Success(user)
    end

    def check(user)
      unless Ability.new(user).can?(:submit, KycTypes::KycEntity)
        return M.Failure(type: :unauthorized_action)
      end

      M.Success(KycService.find_by_user(user.id))
    end

    def submit(kyc)
      model = kyc.to_model

      model.update_attribute(:applying_status, :pending)

      M.Success(model)
    end

    def as_entity(kyc)
      KycTypes::Tier2KycEntity.from_model(kyc)
    end
  end
end
