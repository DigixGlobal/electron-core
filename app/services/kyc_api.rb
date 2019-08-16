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
      "address": address&.downcase || '',
      "newAddress": new_address&.downcase
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

    def request_kyc_server(method, path, payload = {})
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
        'Authorization' => AccessService.access_authorization(method, path, payload)
      )

      req.body = payload.to_json

      begin
        res = https.request(req)

        result = JSON.parse(res.body)

        M.Success(result)
      rescue StandardError
        M.Failure(type: :request_failed)
      end
    end
  end
end
