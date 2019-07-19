# frozen_string_literal: true

class AccountController < ApplicationController
  CHANGE_ETH_ADDRESS_URI = ENV.fetch('CHANGE_ETH_ADDRESS_URI') { 'https://localhost:5000/#/dashboard' }

  def change_eth_address
    token = params[:token]

    result = AccountService.change_eth_address(token)

    error = AppMatcher.result_matcher.call(result) do |m|
      m.success { |_kyc| nil }
      m.failure { |error| error }
    end

    redirect_to "#{CHANGE_ETH_ADDRESS_URI}?error=#{error || ''}"
  end
end
