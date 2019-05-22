# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe ApproveApplyingKycMutation do
    let(:user) { create(:kyc_officer_user) }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }
    let(:kyc) { create(:pending_kyc_tier_2) }

    let(:params) do
      {
        applying_kyc_id: kyc.id,
        expiration_date: generate(:future_date)
      }
    end

    before do
      stub_request(:post, "#{KycApi::SERVER_URL}/tier2Approval")
        .to_return(body: {}.to_json)
    end

    specify 'should work with valid data' do
      expect(mutation.resolve(params)).to(have_no_mutation_errors)
    end

    it 'should fail with missing KYC ' do
      invalid_params = params.merge(applying_kyc_id: SecureRandom.uuid)

      expect(mutation.resolve(invalid_params)).to(have_mutation_errors)
    end

    it 'should fail with invalid KYC ' do
      kyc.update_attribute(:applying_status, :approving)

      expect(mutation.resolve(params)).to(have_mutation_errors)
    end

    it 'should fail with invalid data' do
      invalid_params = params.merge(expiration_date: generate(:past_date))

      expect(mutation.resolve(invalid_params)).to(have_mutation_errors)
    end
  end
end
