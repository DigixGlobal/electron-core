# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SignPricefeedMutation do
    let(:user) { create(:user) }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }
    let(:pair) { generate(:pricefeed_pair) }
    let(:pricefeed_pairs) do
      [
        {
          'pair' => pair,
          'tiers' => [
            params_for(:pricefeed_tier, minimum: 5),
            params_for(:pricefeed_tier, minimum: 10)
          ]
        }
      ]
    end
    let(:amount) { SecureRandom.random_number(15) + 5 }
    let(:params) do
      {
        amount: amount,
        pair: pair
      }
    end

    before do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_blockNumber/)
        .to_return(body: { result: SecureRandom.random_number(1_000_000).to_i.to_s(16) }.to_json)

      Rails.cache.write(
        Prices::FetchPricefeed::PRICEFEED_KEY,
        'data' => {
          'fetchTicks' => pricefeed_pairs
        }
      )
    end

    context 'with valid data' do
      let(:result) { mutation.resolve(params) }

      specify 'should work' do
        expect(result).to(have_no_mutation_errors)
        expect(result[:signed_pricefeed])
          .to(include(*Types::Pricefeed::SignedPricefeedType.fields.keys.map(&:to_sym)))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(mutation.resolve(pair: '', amount: '')).to(have_mutation_errors)
      end

      example 'on user without eth address set' do
        user.update_attribute(:eth_address, nil)
        expect(mutation.resolve(params)).to(have_mutation_errors)
      end

      example 'on tier without matching tier' do
        invalid_params = params.merge(amount: SecureRandom.random_number(5))
        expect(mutation.resolve(invalid_params)).to(have_mutation_errors)
      end

      example 'safely on other errors' do
        WebMock.reset!
        Rails.cache.clear

        expect(mutation.resolve(params)).to(have_mutation_errors)
      end
    end
  end
end
