# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe ChangeEthAddressMutation do
    let(:user) { create(:user) }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }

    let(:eth_address) { generate(:eth_address) }

    before do
      stub_request(:post, "#{KycApi::SERVER_URL}/kyc")
        .to_return(body: {}.to_json)
    end

    specify 'should work with valid data' do
      result = mutation.resolve(eth_address: eth_address)

      expect(result)
        .to(have_no_mutation_errors)
    end

    it 'should fail if repeated' do
      expect(mutation.resolve(eth_address: eth_address)).to(have_no_mutation_errors)
      expect(mutation.resolve(eth_address: eth_address)).to(have_mutation_errors)
    end

    it 'should fail with empty data' do
      expect(mutation.resolve(eth_address: nil))
        .to(have_mutation_errors)
    end
  end
end
