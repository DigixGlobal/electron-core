# frozen_string_literal: true

module Kycs
  class SubmitApplyingKyc
    include Dry::Transaction

    M = Dry::Monads

    step :find_by_user_id
    step :check
    step :validate
    step :submit
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:form_step).filled
        required(:residence_city).filled
        required(:residence_postal_code).filled
        required(:residence_line_1).filled
        required(:residence_line_2).filled
        required(:residence_proof_image).filled
        required(:identification_proof_type).filled
        required(:identification_proof_expiration_date).filled
        required(:identification_proof_image).filled
        required(:identification_proof_number).filled
        required(:identification_pose_image).filled
      end
    end

    def find_by_user_id(user_id)
      unless (user = AccountService.find(user_id))
        return M.Failure(type: :user_not_found)
      end

      M.Success(user)
    end

    def check(user)
      if (kyc = KycService.find_applying_by_user(user.id)) &&
         kyc.status != :drafted.to_s
        return M.Failure(type: :kyc_not_pending)
      end

      unless Ability.new(user).can?(:submit, KycTypes::KycEntity)
        return M.Failure(type: :unauthorized_action)
      end

      M.Success(KycService.find_applying_by_user(user.id))
    end

    def validate(kyc)
      result = schema.call(kyc.to_h)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      M.Success(kyc)
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
