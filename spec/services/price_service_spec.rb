# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceService, type: :service do
  let(:pricefeed_pairs) do
    params_for_list(:pricefeed_pair, 7)
  end
  let(:graphql_body) do
    { 'data' => { 'fetchTicks' => pricefeed_pairs } }
  end

  describe '.fetch_pricefeed' do
    let(:result) { described_class.fetch_pricefeed }

    specify 'should work with an empty cache' do
      Rails.cache.delete(Prices::FetchPricefeed::PRICEFEED_KEY)

      stub = stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
             .to_return(body: graphql_body.to_json)

      expect(result).to(be_success)
      expect(stub).to(have_been_requested)
    end

    specify 'should work with an existing cache' do
      Rails.cache.write(Prices::FetchPricefeed::PRICEFEED_KEY, graphql_body)

      stub = stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
             .to_return(body: '')

      expect(result).to(be_success)
      expect(stub).not_to(have_been_requested)

      new_value = Rails.cache
                       .read(Prices::FetchPricefeed::PRICEFEED_KEY)
                       .dig('data', 'fetchTicks')
                       .map(&:deep_symbolize_keys)

      expect(new_value).to(eq(result.value!))
    end

    specify 'no_cache should work an existing cache' do
      Rails.cache.write(Prices::FetchPricefeed::PRICEFEED_KEY, {})

      stub = stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
             .to_return(body: graphql_body.to_json)

      fresh_result = described_class.fetch_pricefeed(no_cache: true)

      expect(fresh_result).to(be_success)
      expect(stub).to(have_been_requested)
    end

    context 'can fail' do
      before do
        Rails.cache.delete(Prices::FetchPricefeed::PRICEFEED_KEY)
      end

      specify 'with empty pair' do
        stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
          .to_return(body: {}.to_json)

        expect(result).to(be_failure)
        expect(result).to(has_failure_type(:invalid_data))
      end

      specify 'with invalid pair' do
        invalid_pricefeeds = [
          { 'pair' => 'NON_EXISTENT',
            'tiers' => [] },
          { 'pair' => 'eth-usd',
            'tiers' => [{}] },
          { 'pair' => 'xbt-usd',
            'tiers' => [params_for(:pricefeed_tier, name: '')] },
          { 'pair' => 'dai-usd',
            'tiers' => [params_for(:pricefeed_tier, minimum: -1.0)] },
          { 'pair' => 'xau-eth',
            'tiers' => [params_for(:pricefeed_tier, price: -2)] },
          { 'pair' => 'xau-usd',
            'tiers' => [params_for(:pricefeed_tier, index: -2)] }
        ]

        stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
          .to_return(body: { 'data' => { 'fetchTicks' => invalid_pricefeeds } }.to_json)

        expect(result).to(be_failure)
        expect(result).to(has_failure_type(:invalid_data))
      end

      specify 'should clear cache with invalid data' do
        Rails.cache.write(Prices::FetchPricefeed::PRICEFEED_KEY, {})

        expect(result).to(be_failure)
        expect(Rails.cache.exist?(Prices::FetchPricefeed::PRICEFEED_KEY)).to(be_falsy)
      end

      specify 'with connection down' do
        stub_request(:post, Prices::FetchPricefeed::PRICEFEED_URL)
          .to_raise(StandardError)

        expect(result).to(be_failure)
        expect(result).to(has_failure_type(:pricefeed_not_found))
      end
    end
  end

  describe '.sign_pricefeed' do
    let(:pair) { generate(:pricefeed_pair) }
    let(:user) { create(:user) }
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
    let(:result) do
      described_class.sign_pricefeed(
        user_id: user.id,
        pair: pair,
        amount: amount
      )
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

    specify 'should work' do
      expect(result).to(be_success)
    end

    specify 'tiers should be correct' do
      first_tier_result = described_class.sign_pricefeed(
        user_id: user.id,
        pair: pair,
        amount: SecureRandom.random_number(5) + 5
      )

      expect(first_tier_result).to(be_success)
      expect(first_tier_result.value![:price])
        .to(eq(pricefeed_pairs.first.dig('tiers').first['price']))

      second_tier_result = described_class.sign_pricefeed(
        user_id: user.id,
        pair: pair,
        amount: SecureRandom.random_number(10) + 10
      )

      expect(second_tier_result).to(be_success)
      expect(second_tier_result.value![:price])
        .to(eq(pricefeed_pairs.first.dig('tiers').last['price']))
    end

    context 'can fail' do
      example 'with empty params' do
        expect(described_class.sign_pricefeed).to(be_failure)
      end

      context 'on user' do
        example 'when empty' do
          result = described_class.sign_pricefeed(
            pair: pair,
            amount: amount
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:user_not_found))
        end

        example 'with unset address' do
          invalid_user = create(:user, eth_address: nil)

          result = described_class.sign_pricefeed(
            user_id: invalid_user.id,
            pair: pair,
            amount: amount
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:invalid_user))
        end
      end

      context 'on pair' do
        example 'when empty' do
          result = described_class.sign_pricefeed(
            user_id: user.id,
            amount: amount
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:invalid_data))
        end

        example 'when invalid' do
          result = described_class.sign_pricefeed(
            user_id: user.id,
            pair: SecureRandom.hex,
            amount: amount
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:invalid_data))
        end
      end

      context 'on amount' do
        example 'when empty' do
          result = described_class.sign_pricefeed(
            user_id: user.id,
            pair: pair
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:invalid_data))
        end

        example 'when invalid' do
          result = described_class.sign_pricefeed(
            user_id: user.id,
            pair: pair,
            amount: -amount
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:invalid_data))
        end
      end

      context 'on tier' do
        example 'when not found' do
          result = described_class.sign_pricefeed(
            user_id: user.id,
            pair: pair,
            amount: SecureRandom.random_number(5)
          )

          expect(result).to(be_failure)
          expect(result).to(has_failure_type(:tier_not_found))
        end
      end
    end
  end
end
