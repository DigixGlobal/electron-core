# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :draft_tier2_kyc, class: 'Hash' do
    form_step { generate(:positive_integer) }
    residence_city { generate(:city) }
    residence_postal_code { generate(:postal_code) }
    residence_line_1 { generate(:street_address) }
    residence_line_2 { generate(:street_address) }
    residence_line1 { residence_line_1 }
    residence_line2 { residence_line_2 }
    residence_proof_image { generate(:data_url) }
    identification_proof_image { generate(:data_url) }
    identification_proof_type { generate(:kyc_identification_proof_type) }
    identification_proof_number { |_| SecureRandom.hex }
    identification_proof_expiration_date { generate(:future_date) }
    identification_pose_image { generate(:data_url) }
    identification_proof_back_image do
      identification_proof_type == :identity_card.to_s ? generate(:data_url) : nil
    end

    factory :draft_tier2_kyc_params do
      identification_proof_type { generate(:kyc_identification_proof_type).upcase }
      residence_proof_image { generate(:data_url).to_s }
      identification_proof_image { generate(:data_url).to_s }
      identification_pose_image { generate(:data_url).to_s }
      identification_proof_back_image do
        identification_proof_type == :identity_card.to_s.upcase ? generate(:data_url) : nil
      end

      identification_proof_expiration_date { generate(:future_date).strftime('%F') }
    end
  end

  factory :approve_applying_kyc, class: 'Hash' do
    expiration_date { generate(:future_date) }

    factory :approve_applying_kyc_params do
      expiration_date { generate(:future_date).to_s }
    end
  end

  factory :reject_applying_kyc, class: 'Hash' do
    rejection_reason { generate(:rejection_reason) }

    factory :reject_applying_kyc_params, class: 'Hash' do
    end
  end

  factory :mark_kyc_approved, class: 'Hash' do
    address { generate(:eth_address) }
    txhash { generate(:txhash) }
  end
end
