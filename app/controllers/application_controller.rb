# frozen_string_literal: true

require 'dry/monads/do'

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  class UnauthorizedRequest < StandardError; end

  def render_unauthorized_request(error)
    render json: error_response(error),
           status: :unauthorized
  end

  rescue_from UnauthorizedRequest,
              with: :render_unauthorized_request

  def result_response(result = :ok)
    { result: result }
  end

  def error_response(error = :error)
    { error: error }
  end

  private

  def check_authorization
    result = AccessService.check_authorization(request)

    AppMatcher.result_matcher.call(result) do |m|
      m.success { |_| yield }
      m.failure { |error| raise UnauthorizedRequest, error }
    end
  end
end
