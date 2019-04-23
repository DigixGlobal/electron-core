# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe RejectApplyingKycMutation do
    let(:user) { create(:kyc_officer_user) }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }
    let(:kyc) { create(:pending_kyc_tier_2) }
    let(:params) do
      {
        applying_kyc_id: kyc.id,
        rejection_reason: generate(:rejection_reason)
      }
    end

    specify 'should work with valid data' do
      expect(mutation.resolve(params)).to(have_no_mutation_errors)
    end

    it 'should fail with missing KYC ' do
      invalid_params = params.merge(applying_kyc_id: SecureRandom.uuid)

      expect(mutation.resolve(invalid_params)).to(have_mutation_errors)
    end

    it 'should fail with invalid KYC ' do
      kyc.update_attribute(:applying_status, :rejected)

      expect(mutation.resolve(params)).to(have_mutation_errors)
    end

    it 'should fail with invalid data' do
      invalid_params = params.merge(rejection_reason: SecureRandom.hex)

      expect(mutation.resolve(invalid_params)).to(have_mutation_errors)
    end
  end
end
