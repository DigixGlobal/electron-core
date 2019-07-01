# frozen_string_literal: true

module Prices
  class FetchPricefeed
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    PRICEFEED_KEY = 'pricefeed_data'
    PRICEFEED_URL = ENV.fetch('PRICEFEED_URL') { 'http://localhost:24001/api' }
    PRICEFEED_PAIRS = %w[
      xau-usd eth-usd xbt-usd dai-usd xau-eth xau-dai xau-xbt
    ].freeze
    PRICEFEED_QUERY = <<~EOS
      {
        fetchTicks {
          pair
          tiers {
            minimum
            name
            premium
            price
            index
          }
        }
      }
    EOS

    step :fetch
    step :parse
    step :store

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        each do
          required('pair').value(included_in?: PRICEFEED_PAIRS)
          required('tiers').each do
            required('minimum') { (float? | int?) & gteq?(0.0) }
            required('name').filled(:str?)
            required('premium') { (float? | int?) & gteq?(0.0) }
            required('price') { (float? | int?) & gteq?(0.0) }
            required('index') { int? & gteq?(0) }
          end
        end
      end
    end

    def fetch(no_cache: false)
      if no_cache || !Rails.cache.exist?(PRICEFEED_KEY)
        conn = Faraday.new(url: PRICEFEED_URL) do |faraday|
          faraday.request :json
          faraday.request :retry,
                          max: 3,
                          interval: 0.05,
                          interval_randomness: 0.5,
                          backoff_factor: 2
          faraday.response :logger if Rails.env.dev?
          faraday.response :json

          faraday.adapter Faraday.default_adapter
        end

        begin
          resp = conn.post do |req|
            req.body = { 'query' => PRICEFEED_QUERY }
          end

          return M.Failure(type: :pricefeed_not_found) unless resp.success?

          M.Success(resp.body)
        rescue StandardError
          M.Failure(type: :pricefeed_not_found)
        end
      else
        M.Success(Rails.cache.read(PRICEFEED_KEY))
      end
    end

    def parse(data)
      unless data
        Rails.cache.delete(PRICEFEED_KEY)
        return M.Failure(type: :pricefeed_not_found)
      end

      unless data.is_a?(Hash) &&
             (pricefeed_data = data.dig('data', 'fetchTicks')) &&
             pricefeed_data.is_a?(Array)
        Rails.cache.delete(PRICEFEED_KEY)
        return M.Failure(type: :invalid_data)
      end

      result = schema.call(pricefeed_data)

      unless result.success?
        Rails.cache.delete(PRICEFEED_KEY)
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      M.Success(data)
    end

    def store(data)
      Rails.cache.write(PRICEFEED_KEY, data, expires: 1.minute)

      M.Success(data.dig('data', 'fetchTicks').map(&:deep_symbolize_keys))
    end
  end
end
