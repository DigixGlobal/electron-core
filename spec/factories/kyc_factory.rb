# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :kyc, class: 'Kyc' do
    tier { :tier_1 }
    applying_status { nil }

    first_name { generate(:first_name) }
    last_name { generate(:first_name) }
    birthdate { generate(:birthdate) }
    citizenship { generate(:unblocked_country_value) }
    residence_country { generate(:unblocked_country_value) }

    factory :kyc_tier_2 do
      form_step { generate(:positive_integer) }
      residence_city { generate(:city) }
      residence_postal_code { generate(:postal_code) }
      residence_line_1 { generate(:street_address) }
      residence_line_2 { generate(:street_address) }
      identification_proof_type { generate(:kyc_identification_proof_type) }
      identification_proof_number { |_| SecureRandom.hex }
      identification_proof_expiration_date { generate(:future_date) }

      residence_proof_image { generate(:image) }
      identification_proof_image { generate(:image) }
      identification_proof_back_image do
        identification_proof_type == :identity_card.to_s ? generate(:image) : nil
      end
      identification_pose_image { generate(:image) }

      factory :drafted_kyc_tier_2 do
        applying_status { :drafted }
      end

      factory :pending_kyc_tier_2 do
        applying_status { :pending }
      end

      factory :approved_kyc_tier_2 do
        applying_status { :approved }
      end

      factory :approving_kyc_tier_2 do
        applying_status { :approving }
      end

      factory :rejected_kyc_tier_2 do
        applying_status { :rejected }
      end
    end

    association :user, factory: :user
  end
end
