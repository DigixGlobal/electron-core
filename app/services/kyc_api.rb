# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'net/https'

module KycApi
  SERVER_URL = ENV.fetch('KYC_PREPROCESSOR_SERVER_URL') { 'http://localhost:5079' }

  M = Dry::Monads

  def self.change_eth_address(address, new_address)
    # TODO: Not yet full specified
    request_kyc_server(
      'POST',
      '/addressChange',
      "address": address.downcase,
      "newAddress": new_address.downcase
    )
  end

  def self.approve_to_tier2(address, expiration_date)
    # TODO: Not yet full specified
    request_kyc_server(
      'POST',
      '/tier2Approval',
      "address": address.downcase,
      "expiry": expiration_date.to_time.to_i
    )
  end

  class << self
    private

    SERVER_SECRET = ENV.fetch('SERVER_PAIR_HMAC_SECRET') { 'mysecret' }
    SERVER_TOKEN = '16a7b'
    NONCE_KEY = 'kyc_api_nonce'

    def access_signature(method, path, payload, nonce)
      "#{method.upcase}#{path}#{payload.to_json}#{nonce}"
    end

    def request_signature(request)
      access_signature(
        request.method,
        request.original_fullpath,
        next_nonce,
        request.body
      )
    end

    def hash_message(message)
      digest = OpenSSL::Digest.new('sha256')

      OpenSSL::HMAC.hexdigest(digest, SERVER_SECRET, message)
    end

    def next_nonce
      Rails.cache.fetch(NONCE_KEY) { 0 }
      Rails.cache.increment(NONCE_KEY)
    end

    def request_kyc_server(method, path, payload = {})
      new_nonce = next_nonce
      signature = access_signature(method, path, payload, new_nonce)

      uri = URI.parse("#{SERVER_URL}#{path}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = uri.scheme == 'https'

      request_class = case method.upcase
                      when 'POST'
                        Net::HTTP::Post
                      when 'GET'
                        Net::HTTP::Get
                      end

      req = request_class.new(
        uri.path,
        'Content-Type' => 'application/json',
        'Authorization' => {
          "access-token": SERVER_TOKEN,
          "access-nonce": new_nonce,
          "access-sign": hash_message(signature)
        }.map { |key, value| "#{key}='#{value}'" }.join(', ')
      )

      req.body = payload.to_json

      begin
        res = https.request(req)

        result = JSON.parse(res.body)

        M.Success(result)
      rescue JSON::ParserError
        Rails.logger.error("Invalid response type from #{SERVER_URL}#{path}: #{res.body.inspect}")

        M.Success(nil)
      rescue StandardError
        M.Failure(type: :request_failed)
      end
    end
  end
end
