# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'net/https'

module EthereumApi
  SERVER_URL = ENV.fetch('INFURA_SERVER_URL') { 'http://localhost:8545/' }

  M = Dry::Monads

  def self.fetch_latest_block
    request_ethereum_server(
      'eth_blockNumber',
      []
    ).bind { |block_number| fetch_block_by_block_number(block_number) }
  end

  def self.fetch_block_by_block_number(block_number)
    request_ethereum_server(
      'eth_getBlockByNumber',
      [block_number, false]
    )
  end

  class << self
    private

    def request_ethereum_server(method_name, method_args)
      uri = URI.parse(SERVER_URL)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = uri.scheme == 'https'

      req = Net::HTTP::Post.new(
        uri.path,
        'Content-Type' => 'application/json'
      )

      req.body = {
        jsonrpc: '2.0',
        method: method_name,
        params: method_args,
        id: 1
      }.to_json

      begin
        res = https.request(req)

        result = JSON.parse(res.body)

        if (data = result.fetch('result', nil))
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
