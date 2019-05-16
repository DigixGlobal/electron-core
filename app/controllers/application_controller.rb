# frozen_string_literal: true

require 'dry/monads/do'

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  private

  class CheckTransaction
    include Dry::Transaction
    include Dry::Monads::Do

    M = Dry::Monads

    step :extract
    step :validate
    step :update

    private

    ENTRY_PATTERN = /([\w\-]+)='(\w+)'/i.freeze

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:a)
          .filled(format?: VERIFICATION_PATTERN)
      end
    end

    def extract(this_request)
      unless (authorization_header = request.headers.fetch('Authorization', nil))
        return M.Failure(type: :invalid_authorization)
      end

      M.Success(authorization_header
        .scan(ENTRY_PATTERN)
        .deep_transform_keys!(&:underscore)
        .to_h)
    end

    def validate(attrs)
    end

    def update(x)
    end
  end

  def check_authorization
    unless (request_nonce = request.headers.fetch('ACCESS-NONCE', '').to_i)
      raise InfoServer::InvalidRequest, :missing_access_nonce
    end
  end
end
