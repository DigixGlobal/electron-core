# frozen_string_literal: true

module AccessService
  SERVER_SECRET = ENV.fetch('SERVER_PAIR_HMAC_SECRET') { 'mysecret' }
  SERVER_TOKEN = ENV.fetch('SERVER_TOKEN') { '16a7b' }

  NONCE_KEY = 'electron_api_nonce'
  KYC_NONCE_KEY = 'kyc_api_nonce'

  def self.current_kyc_nonce
    Rails.cache.fetch(KYC_NONCE_KEY) { 0 }
  end

  def self.update_kyc_nonce(new_nonce)
    Rails.cache.write(KYC_NONCE_KEY, new_nonce)
  end

  def self.current_nonce
    Rails.cache.fetch(NONCE_KEY) { 0 }
  end

  def self.next_nonce
    Rails.cache.fetch(NONCE_KEY) { 0 }
    Rails.cache.increment(NONCE_KEY)
  end

  def self.hash_message(message)
    digest = OpenSSL::Digest.new('sha256')

    OpenSSL::HMAC.hexdigest(digest, SERVER_SECRET, message)
  end

  def self.access_signature(method, path, payload, nonce)
    "#{method.upcase}#{path}#{payload.to_json}#{nonce}"
  end

  def self.access_authorization(method, path, payload)
    new_nonce = next_nonce
    signature = access_signature(method, path, payload, new_nonce)

    {
      "access-token": SERVER_TOKEN,
      "access-nonce": new_nonce,
      "access-sign": hash_message(signature)
    }
      .map { |key, value| "#{key}='#{value}'" }
      .join(', ')
  end

  class CheckAuthorization
    include Dry::Transaction

    M = Dry::Monads

    map :extract
    step :validate
    step :update

    private

    ENTRY_PATTERN = /([\w\-]+)='(\w+)'/i.freeze

    def schema
      Dry::Validation.Schema(AppSchema) do
        configure do
          option :current_signature
          option :current_nonce

          def self.messages
            super.merge(en: { errors: {
                          valid_nonce?: 'is not a valid nonce',
                          valid_signature?: 'is not a valid signature'
                        } })
          end

          def valid_nonce?(value)
            value > current_nonce
          end

          def valid_signature?(value)
            value == current_signature
          end
        end

        required(:access_token)
          .filled(:str?)
        required(:access_nonce)
          .filled(:int?, :valid_nonce?)
        required(:access_sign)
          .filled(:str?, :valid_signature?)
      end
    end

    def extract(request)
      {
        method: request.method,
        path: request.original_fullpath,
        payload: JSON.parse(request.raw_post),
        authorization:
          request.headers
                 .fetch('Authorization', '')
                 .scan(ENTRY_PATTERN)
                 .to_h
      }
    end

    def validate(authorization:, method:, path:, payload:)
      nonce = authorization.fetch('access-nonce', '').to_i

      current_signature = AccessService.hash_message(
        AccessService.access_signature(method, path, payload, nonce)
      )
      current_nonce = AccessService.current_kyc_nonce

      result = schema.with(current_signature: current_signature, current_nonce: current_nonce).call(
        access_token: authorization.fetch('access-token', ''),
        access_nonce: nonce,
        access_sign: authorization.fetch('access-sign', '')
      )

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: true))
      end

      result.to_monad
            .fmap do |params|
        { nonce: params[:access_nonce] }
      end
    end

    def update(nonce:)
      AccessService.update_kyc_nonce(nonce)

      M.Success()
    end
  end

  def self.check_authorization(request)
    CheckAuthorization.new.call(request)
  end
end
