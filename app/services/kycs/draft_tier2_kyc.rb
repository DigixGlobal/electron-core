# frozen_string_literal: true

require 'cancancan'

module Kycs
  class DraftTier2Kyc
    include Dry::Transaction

    M = Dry::Monads

    step :check
    step :validate
    step :draft
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:residence_proof_type)
          .filled(included_in?: Kyc.residence_proof_types.keys)
        required(:residence_city)
          .filled(max_size?: 250)
        required(:residence_postal_code)
          .filled(max_size?: 12, format?: /\A[a-z0-9][a-z0-9\-\s]{0,10}[a-z0-9]\z/i)
        required(:residence_line_1)
          .filled(max_size?: 1000)
        required(:residence_line_2)
          .filled(max_size?: 1000)
        required(:residence_proof_image)
          .filled(type?: URI::Data)
        required(:identification_proof_number)
          .filled(max_size?: 50)
        required(:identification_proof_type)
          .filled(included_in?: Kyc.identification_proof_types.keys)
        required(:identification_proof_expiration_date)
          .filled(:date?, :future_date?)
        required(:identification_proof_image)
          .filled(type?: URI::Data)
        required(:identification_pose_image)
          .filled(type?: URI::Data)
      end
    end

    def check(user_id:, attrs:)
      unless (user = AccountService.find(user_id)) &&
             Ability.new(user).can?(:draft, KycTypes::Tier2KycEntity)
        return Failure(type: :unauthorized_action)
      end

      M.Success(user_id: user_id, attrs: attrs)
    end

    def validate(user_id:, attrs:)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: true))
      end

      result.to_monad.fmap { |params| { params: params, user_id: user_id } }
    end

    def draft(user_id:, params:)
      image_fields = %i[
        residence_proof_image
        identification_pose_image
        identification_proof_image
      ]

      attrs = AppSchema.preprocess_spaces(
        params.slice(*(schema.rules.keys - image_fields))
      )

      kyc = Kyc.kept.find_by(user_id: user_id)
      kyc.applying_status = :drafted

      kyc.residence_proof_image_data_uri = encode_image(params[:residence_proof_image])
      kyc.identification_proof_image_data_uri = encode_image(params[:identification_proof_image])
      kyc.identification_pose_image_data_uri = encode_image(params[:identification_proof_image])

      return Failure(type: :invalid_data, errors: kyc.errors) unless kyc.update_attributes(attrs)

      M.Success(kyc)
    end

    def as_entity(kyc)
      KycTypes::Tier2KycEntity.from_model(kyc)
    end

    def encode_image(uri)
      uri.to_s
    end
  end
end
