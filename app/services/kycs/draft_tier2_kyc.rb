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
        required(:form_step)
          .filled(:int?, gteq?: 0)
        optional(:residence_city)
          .filled(max_size?: 250)
        optional(:residence_postal_code)
          .filled(max_size?: 12, format?: /\A[a-z0-9][a-z0-9\-\s]{0,10}[a-z0-9]\z/i)
        optional(:residence_line_1)
          .filled(max_size?: 1000)
        optional(:residence_line_2)
          .filled(max_size?: 1000)
        optional(:residence_proof_image)
          .filled(type?: URI::Data)
        optional(:identification_proof_number)
          .filled(max_size?: 50)
        optional(:identification_proof_type)
          .filled(included_in?: Kyc.identification_proof_types.keys)
        optional(:identification_proof_expiration_date)
          .filled(:date?, :future_date?)
        optional(:identification_proof_image)
          .filled(type?: URI::Data)
        optional(:identification_proof_back_image)
          .filled(type?: URI::Data)
        optional(:identification_pose_image)
          .filled(type?: URI::Data)

        rule(identification_proof_back_image: %i[
               identification_proof_type
               identification_proof_back_image
             ]) do |type, back_image|
          type.eql?(:identity_card.to_s).then(back_image.filled?)
        end
      end
    end

    def check(user_id:, attrs:)
      unless (user = AccountService.find(user_id))
        return M.Failure(type: :user_not_found)
      end

      if (kyc = KycService.find_applying_by_user(user.id)) &&
         ![:drafted.to_s, :rejected.to_s].member?(kyc.status)
        return M.Failure(type: :kyc_not_drafted)
      end

      unless Ability.new(user).can?(:draft, KycTypes::Tier2KycEntity)
        return M.Failure(type: :unauthorized_action)
      end

      M.Success(user_id: user_id, attrs: attrs)
    end

    def validate(user_id:, attrs:)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad.fmap { |params| { params: params, user_id: user_id } }
    end

    def draft(user_id:, params:)
      image_fields = %i[
        residence_proof_image
        identification_pose_image
        identification_proof_image
        identification_proof_back_image
      ]

      attrs = AppSchema.preprocess_spaces(
        params.slice(*(schema.rules.keys - image_fields))
      )

      kyc = Kyc.kept.find_by(user_id: user_id)
      kyc.applying_status = :drafted

      if (data_uri = params[:residence_proof_image])
        kyc.residence_proof_image_data_uri = encode_image(data_uri)
      end

      if (data_uri = params[:identification_proof_image])
        kyc.identification_proof_image_data_uri = encode_image(data_uri)
      end

      if (data_uri = params[:identification_proof_back_image])
        kyc.identification_proof_back_image_data_uri = encode_image(data_uri)
      end

      if (data_uri = params[:identification_pose_image])
        kyc.identification_pose_image_data_uri = encode_image(data_uri)
      end

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
