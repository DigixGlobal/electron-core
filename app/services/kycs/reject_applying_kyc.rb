# frozen_string_literal: true

module Kycs
  class RejectApplyingKyc
    include Dry::Transaction

    M = Dry::Monads

    step :find_by_officer_id
    step :find_by_applying_id
    step :check
    step :validate
    step :reject

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:rejection_reason)
          .filled(:rejection_reason?)
      end
    end

    def find_by_officer_id(officer_id:, **attrs)
      unless (officer = AccountService.find(officer_id))
        return M.Failure(type: :officer_not_found)
      end

      M.Success(officer: officer, **attrs)
    end

    def find_by_applying_id(applying_kyc_id:, **attrs)
      unless (kyc = KycService.find_applying(applying_kyc_id))
        return M.Failure(type: :kyc_not_found)
      end

      M.Success(kyc: kyc, **attrs)
    end

    def check(kyc:, officer:, **attrs)
      return M.Failure(type: :kyc_not_pending) unless kyc.status == :pending.to_s
      return M.Failure(type: :unauthorized_action) unless Ability.new(officer).can?(:reject, kyc)

      M.Success(kyc: kyc, officer: officer, **attrs)
    end

    def validate(kyc:, officer:, attrs:)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad.fmap do |params|
        {
          kyc: kyc,
          officer: officer,
          rejection_reason: params[:rejection_reason]
        }
      end
    end

    def reject(kyc:, officer:, rejection_reason:)
      model = kyc.to_model

      unless model.update_attributes(
        applying_status: :rejected,
        officer_id: officer.id,
        rejection_reason: rejection_reason
      )
        return M.Failure(type: :invalid_data, errors: model.errors)
      end

      case kyc
      when KycTypes::Tier2KycEntity
        M.Success(KycTypes::Tier2KycEntity.from_model(model))
      end
    end
  end
end
