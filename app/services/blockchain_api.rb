# frozen_string_literal: true

module BlockchainApi
  BLOCKCHAIN_URL = ENV.fetch('BLOCKCHAIN_URL') { 'http://localhost:8545/' }

  M = Dry::Monads

  def self.fetch_latest_block_number
    request_ethereum_server(
      'eth_blockNumber',
      []
    ).fmap { |block_number| to_int(block_number) }
  end

  def self.fetch_latest_block
    request_ethereum_server(
      'eth_blockNumber',
      []
    ).bind { |block_number| fetch_block_by_block_number(block_number) }
  end

  def self.fetch_block_by_block_number(block_number)
    request_ethereum_server(
      'eth_getBlockByNumber',
      [to_hex(block_number), false]
    )
  end

  class << self
    private

    def to_hex(value)
      if value.is_a?(Integer)
        "0x#{value.to_s(16)}"
      else
        value
      end
    end

    def to_int(value)
      if value.is_a?(String)
        value.to_i(16)
      else
        value
      end
    end

    def request_ethereum_server(method_name, method_args)
      conn = Faraday.new(url: BLOCKCHAIN_URL) do |faraday|
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
          req.body = {
            jsonrpc: '2.0',
            method: method_name,
            params: method_args,
            id: 1
          }.to_json
        end

        if (data = resp.body.fetch('result', nil))
          M.Success(convert_hash_keys(data))
        else
          M.Failure(type: :request_failed)
        end
      rescue StandardError
        M.Failure(type: :request_failed)
      end
    end

    def convert_hash_keys(value)
      case value
      when Hash
        value.deep_transform_keys!(&:underscore)
      else
        value
      end
    end
  end
end
