# frozen_string_literal: true

module PriceService
  def self.fetch_pricefeed(no_cache: false)
    Prices::FetchPricefeed.new.call(no_cache: no_cache)
  end

  def self.sign_pricefeed(user_id: nil, pair: nil, amount: nil)
    Prices::SignPricefeed.new.call(user_id: user_id, pair: pair, amount: amount)
  end
end
