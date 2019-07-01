# frozen_string_literal: true

module Kycs
  class MarkKycApproved
    include Dry::Transaction

    M = Dry::Monads

    step :validate
    step :find_by_address
    step :check
    step :approve

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:address)
          .filled(:eth_address?)
        required(:txhash)
          .filled(:str?)
      end
    end

    def validate(attrs)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad
    end

    def find_by_address(params)
      unless (user = AccountService.find_by_address(params[:address]))
        return M.Failure(type: :user_not_found)
      end

      applying_kyc = KycService.find_applying_by_user(user.id)

      M.Success(kyc: applying_kyc, txhash: params[:txhash])
    end

    def check(kyc:, txhash:)
      return M.Failure(type: :invalid_kyc) unless kyc.status == :approving.to_s

      M.Success(kyc: kyc, txhash: txhash)
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
