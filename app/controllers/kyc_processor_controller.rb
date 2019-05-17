# frozen_string_literal: true

class KycProcessorController < ApplicationController
  around_action :check_authorization

  def approve_addresses
    items = JSON.parse(request.raw_post)

    unless items.is_a?(Array)
      return render status: :unprocessable_entity,
                    json: error_response(:invalid_data)
    end

    updated = []

    items.map do |attrs|
      address = attrs.fetch('address', '')

      result = KycService.mark_kyc_approved(
        address: address,
        txhash: attrs.fetch('txhash', '')
      )

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |_kyc| updated << address }
        m.failure { |_error| nil }
      end
    end

    render json: result_response(updated)
  end

  def confirm_changes
    render json: result_response(:ok)
  end
end
