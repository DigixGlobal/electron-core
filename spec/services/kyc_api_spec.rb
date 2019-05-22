# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KycApi, type: :api do
  let(:api) { described_class }

  describe '.change_eth_address' do
    let(:url) { "#{KycApi::SERVER_URL}/addressChange" }
    let(:address) { generate(:eth_address) }
    let(:new_address) { generate(:eth_address) }

    specify 'should work' do
      stub = stub_request(:post, url)
             .to_return(body: {}.to_json)

      expect(api.change_eth_address(address, new_address)).to(be_success)
      expect(stub).to(have_been_requested)

      expect(a_request(:post, url)
               .with(body: hash_including(
                 "address": be_instance_of(String),
                 "newAddress": be_instance_of(String)
               ))).to(have_been_made)
    end

    it 'should fail safely when KYC server is down' do
      stub_request(:post, url)
        .to_raise(StandardError)

      expect(api.change_eth_address(address, new_address))
        .to(has_failure_type(:request_failed))
    end

    describe 'actual response', vcr: true do
      it 'should match expectations' do
        pending 'not yet implemented'

        VCR.use_cassette('approve_to_tier2') do
          value = api.change_eth_address(address, new_address).value!

          expect(value).to(eq(nil))
        end
      end
    end
  end

  describe '.approve_to_tier2' do
    let(:url) { "#{KycApi::SERVER_URL}/tier2Approval" }
    let(:address) { generate(:eth_address) }
    let(:expiration_date) { generate(:future_date) }

    specify 'should work' do
      stub = stub_request(:post, url)
             .to_return(body: {}.to_json)

      expect(api.approve_to_tier2(address, expiration_date)).to(be_success)
      expect(stub).to(have_been_requested)

      expect(a_request(:post, url)
               .with(body: hash_including(
                 "address": be_instance_of(String),
                 "expiry": be_instance_of(Integer)
               ))).to(have_been_made)
    end

    it 'should fail safely when KYC server is down' do
      stub_request(:post, url)
        .to_raise(StandardError)

      expect(api.approve_to_tier2(address, expiration_date))
        .to(has_failure_type(:request_failed))
    end

    describe 'actual response', vcr: true do
      it 'should match expectations' do
        pending 'not yet implemented'

        VCR.use_cassette('approve_to_tier2') do
          value = api.approve_to_tier2(address, expiration_date).value!

          expect(value).to(eq(nil))
        end
      end
    end
  end
end
