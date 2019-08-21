# frozen_string_literal: true

module KycTypes
  class KycEntity < SupportTypes::Entity
    attribute(:user_id, Types::String)
    attribute(:officer_id, Types::String)

    attribute(:tier, Types::String)
    attribute(:expiration_date, Types::Date)

    attribute(:first_name, Types::String.optional)
    attribute(:last_name, Types::String.optional)
    attribute(:birthdate, Types::Date.optional)
    attribute(:citizenship, Types::String.optional)

    attribute :residence do
      attribute(:country, Types::String.optional)
      attribute(:city, Types::String.optional)
      attribute(:postal_code, Types::String.optional)
      attribute(:line_1, Types::String.optional)
      attribute(:line_2, Types::String.optional)
    end

    attribute :residence_proof do
      attribute(:image, Types::Hash.optional)
    end

    attribute :identification_proof do
      attribute(:number, Types::String.optional)
      attribute(:expiration_date, Types::Date.optional)
      attribute(:image, Types::Hash.optional)
      attribute(:back_image, Types::Hash.optional)
      attribute(:type, Types::String.optional)
    end

    attribute :identification_pose do
      attribute(:image, Types::Hash.optional)
    end

    attribute(:created_at, Types::DateTime)
    attribute(:updated_at, Types::DateTime)

    def self.from_model(model)
      new(
        id: model.id,
        user_id: model.user_id,
        officer_id: model.officer_id,
        tier: model.tier,
        expiration_date: model.expiration_date,
        first_name: model.first_name,
        last_name: model.last_name,
        birthdate: model.birthdate,
        citizenship: model.citizenship,
        residence: {
          country: model.residence_country,
          city: model.residence_city,
          postal_code: model.residence_postal_code,
          line_1: model.residence_line_1,
          line_2: model.residence_line_2
        },
        residence_proof: {
          image: model.residence_proof_image
        },
        identification_proof: {
          number: model.identification_proof_number,
          type: model.identification_proof_type,
          image: model.identification_proof_image,
          back_image: model.identification_proof_back_image,
          expiration_date: model.identification_proof_expiration_date
        },
        identification_pose: {
          image: model.identification_pose_image
        },

        created_at: model.created_at,
        updated_at: model.updated_at
      )
    end

    def to_model
      Kyc.find(id)
    end
  end

  class Tier2KycEntity < SupportTypes::Entity
    attribute(:user_id, Types::String)
    attribute(:officer_id, Types::String)
    attribute(:form_step, Types::Integer)

    attribute(:status, Types::String)
    attribute(:expiration_date, Types::Date)
    attribute(:rejection_reason, Types::String)

    attribute(:residence_proof_image, Types::Hash)
    attribute(:residence_city, Types::String)
    attribute(:residence_postal_code, Types::String)
    attribute(:residence_line_1, Types::String)
    attribute(:residence_line_2, Types::String)
    attribute(:identification_proof_number, Types::String)
    attribute(:identification_proof_type, Types::String)
    attribute(:identification_proof_image, Types::Hash)
    attribute(:identification_proof_back_image, Types::Hash)
    attribute(:identification_proof_expiration_date, Types::Date)
    attribute(:identification_pose_image, Types::Hash)

    attribute(:created_at, Types::DateTime)
    attribute(:updated_at, Types::DateTime)

    def self.from_model(model)
      new(
        id: model.id,
        user_id: model.user_id,
        officer_id: model.officer_id,
        form_step: model.form_step,

        status: model.applying_status,
        expiration_date: model.expiration_date,
        rejection_reason: model.rejection_reason,

        residence_proof_image: model.residence_proof_image,
        residence_city: model.residence_city,
        residence_postal_code: model.residence_postal_code,
        residence_line_1: model.residence_line_1,
        residence_line_2: model.residence_line_2,
        identification_proof_number: model.identification_proof_number,
        identification_proof_type: model.identification_proof_type,
        identification_proof_image: model.identification_proof_image,
        identification_proof_back_image: model.identification_proof_back_image,
        identification_proof_expiration_date: model.identification_proof_expiration_date,
        identification_pose_image: model.identification_pose_image,

        created_at: model.updated_at,
        updated_at: model.updated_at
      )
    end

    def to_model
      Kyc.find(id)
    end
  end
end
