# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :pricefeed_tier, class: 'Hash' do
    name { |_| generate(:pricefeed_name) }
    minimum { |_| generate(:pricefeed_minimum) }
    premium { |_| SecureRandom.rand }
    price { |_| generate(:price) }
    index { |_| SecureRandom.random_number(1000) + 1 }
  end

  factory :pricefeed_pair, class: 'Hash' do
    pair { |_| generate(:pricefeed_pair) }

    after(:params) do |pricefeed, _evaluator|
      pricefeed['tiers'] = params_for_list(:pricefeed_tier, 3)
    end
  end
end
