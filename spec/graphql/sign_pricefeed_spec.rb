# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'signPricefeed mutation', type: :schema do
  let(:context) { { current_user: create(:user) } }
  let(:query) do
    <<~GQL
      mutation($pair: PricefeedPairEnum!, $amount: PositiveFloat!) {
        signPricefeed(input: { pair: $pair, amount: $amount }) {
          signedPricefeed {
            payload
            price
            signature
            signer
          }
          errors {
            field
            message
          }
        }
      }
    GQL
  end

  let(:key) { 'signPricefeed' }
  let(:pair) { generate(:open_pricefeed_pair) }
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
      'amount' => amount,
      'pair' => pair.upcase.gsub('-', '_')
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

  specify 'should work with valid data' do
    expect(execute(query, params, context))
      .to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, {}, context)).to(have_graphql_errors(key))
  end

  specify 'should fail without a current user' do
    expect(execute(query, params)).to(have_graphql_errors(key))
  end
end
