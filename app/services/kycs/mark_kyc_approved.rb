# frozen_string_literal: true

require 'dry/monads/maybe'

module Kycs
  class MarkKycApproved
    include Dry::Transaction

    M = Dry::Monads

    step :find_by_id
    step :check
    step :validate
    step :approve

    private

    def find_by_id(id:, **attrs)
      return M.Failure(type: :kyc_not_found) unless (kyc = KycService.find_applying(id))

      M.Success(kyc: kyc, **attrs)
    end

    def check(kyc:, **attrs)
      return M.Failure(type: :invalid_kyc) unless kyc.status == :approving.to_s

      M.Success(kyc: kyc, **attrs)
    end

    def validate(kyc:, attrs:)
      M.Success(kyc: kyc, attrs: attrs)
    end

    def approve(kyc:, **_attrs)
      model = kyc.to_model

      case kyc
      when KycTypes::Tier2KycEntity
        model.update_attributes(
          applying_status: :approved,
          tier: :tier_2
        )

        M.Success(KycTypes::Tier2KycEntity.from_model(model))
      end
    end
  end
end
