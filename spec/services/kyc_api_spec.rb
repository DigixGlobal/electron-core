# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KycApi, type: :api do
  let(:api) { described_class }

  describe '.change_eth_address' do
    let(:address) { generate(:eth_address) }
    let(:new_address) { generate(:eth_address) }

    specify 'should work' do
      stub = stub_request(:post, "#{KycApi::SERVER_URL}/kyc")
             .to_return(body: {}.to_json)

      expect(api.change_eth_address(address, new_address)).to(be_success)
      expect(stub).to(have_been_requested)
    end

    it 'should fail safely when KYC server is down' do
      stub_request(:post, "#{KycApi::SERVER_URL}/kyc")
        .to_raise(StandardError)

      expect(api.change_eth_address(address, new_address))
        .to(has_failure_type(:request_failed))
    end
  end

  describe '.approve_to_tier2' do
    let(:address) { generate(:eth_address) }
    let(:expiration_date) { generate(:future_date) }

    specify 'should work' do
      stub = stub_request(:post, "#{KycApi::SERVER_URL}/kycTier2")
             .to_return(body: {}.to_json)

      expect(api.approve_to_tier2(address, expiration_date)).to(be_success)
      expect(stub).to(have_been_requested)
    end

    it 'should fail safely when KYC server is down' do
      stub_request(:post, "#{KycApi::SERVER_URL}/kycTier2")
        .to_raise(StandardError)

      expect(api.approve_to_tier2(address, expiration_date))
        .to(has_failure_type(:request_failed))
    end
  end
end
