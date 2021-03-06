# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  sequence(:kyc_identification_proof_type) { |_| Kyc.identification_proof_types.keys.sample }
end
