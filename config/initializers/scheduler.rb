# frozen_string_literal: true

require 'rufus-scheduler'

require_relative '../boot'

Rufus::Scheduler.singleton.every '30s' do
  Rails.logger.info "#{Time.now}: Fetching new pricefeeds"

  result = PriceService.fetch_pricefeed(no_cache: true)

  AppMatcher.result_matcher.call(result) do |m|
    m.success do |_|
      Rails.logger.info "#{Time.now}: Done fetching new pricefeed"
    end

    m.failure do |error|
      Rails.logger.error "#{Time.now}: Error in fetching pricefeed: #{error}"
    end
  end

  Rails.logger.flush
end
