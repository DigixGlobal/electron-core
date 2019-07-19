# frozen_string_literal: true

class AccountController < ApplicationController
  CHANGE_ETH_ADDRESS_URI = ENV.fetch('CHANGE_ETH_ADDRESS_URI') do
    'https://localhost:5000/#/portal/dashboard'
  end

  def change_eth_address
    token = params[:token]

    result = AccountService.change_eth_address(token)

    error = AppMatcher.result_matcher.call(result) do |m|
      m.success { |_kyc| nil }
      m.failure { |inner_error| inner_error }
    end

    redirect_to "#{CHANGE_ETH_ADDRESS_URI}?error=#{error || ''}"
  end
end
