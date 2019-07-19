# frozen_string_literal: true

module Kycs
  class RegisterKyc
    include Dry::Transaction

    M = Dry::Monads

    step :validate
    step :save
    map :as_entity

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        configure do
          def self.messages
            super.merge(en: { errors: {
                          birthdate?: 'is not of legal age'
                        } })
          end

          def birthdate?(value)
            value <= Kyc::MINIMUM_AGE.years.ago
          end
        end

        required(:first_name)
          .filled(max_size?: 150)
        required(:last_name)
          .filled(max_size?: 150)
        required(:birthdate)
          .filled(:date?, :birthdate?)
        required(:country_of_residence)
          .filled(:str?, :legal_country?, max_size?: 50)
        required(:citizenship)
          .filled(:str?, :legal_country?, max_size?: 50)
      end
    end

    def validate(user_id:, attrs:)
      result = schema.call(attrs)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad.fmap { |params| { params: params, user_id: user_id } }
    end

    def save(user_id:, params:)
      return Failure(type: :kyc_already_created) if Kyc.kept.find_by(user_id: user_id)

      attrs = AppSchema.preprocess_spaces(params.slice(*schema.rules.keys))
      attrs[:residence_country] = attrs.delete(:country_of_residence)

      kyc = Kyc.new(attrs)
      kyc.applying_status = nil
      kyc.user_id = user_id
      kyc.tier = :tier_1

      return Failure(type: :invalid_data, errors: kyc.errors) unless kyc.save

      M.Success(kyc)
    end

    def as_entity(kyc)
      KycTypes::KycEntity.from_model(kyc)
    end
  end
end
