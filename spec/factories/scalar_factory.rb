# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  sequence(:positive_float) { |_| Faker::Commerce.price }

  sequence(:boolean) { |_| Faker::Boolean.boolean }
  sequence(:uid) { |_| SecureRandom.random_number(1_000_000) }
  sequence(:email) { |_| Faker::Internet.safe_email }
  sequence(:password) { |_| Faker::Internet.password(6, 30) }

  sequence(:first_name) { |_| Faker::Name.first_name }
  sequence(:last_name) { |_| Faker::Name.last_name }
  sequence(:birthdate) { |_| Faker::Date.birthday(Kyc::MINIMUM_AGE) }
  sequence(:version) { |_| Faker::App.semantic_version }

  sequence(:city) { |_| Faker::Address.city }
  sequence(:postal_code) { |_| Faker::Address.postcode }
  sequence(:street_address) { |_| Faker::Address.street_address }
  sequence(:verification_code) do |_|
    "#{Random.rand(9_999_000..9_999_900)}-aB-9F"
  end

  sequence(:data_url) do |_|
    URI::Data.new(
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII='
    )
  end
  sequence(:image) do |_|
    StringIO.new(
      URI::Data.new(
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII='
      ).data
    )
  end
  sequence(:date) { |_| Faker::Date.between(1.years.ago, 1.years.since) }
  sequence(:future_date) { |_| Faker::Date.between(1.day.since, 10.years.since) }
  sequence(:past_date) { |_| Faker::Date.backward(SecureRandom.random_number(1..100)) }

  sequence(:eth_address) { |_| Faker::Blockchain::Ethereum.address }
  sequence(:txhash) { |_| Faker::Blockchain::Ethereum.address }

  sequence(:ip_address) { |_| Faker::Internet.public_ip_v4_address }
  sequence(:private_ip_address) { |_| Faker::Internet.private_ip_v4_address }

  sequence(:price) { |_| Faker::Commerce.price }
  sequence(:pricefeed_name) { |_| "level_#{SecureRandom.random_number(2) + 1}" }
  sequence(:pricefeed_minimum) { |_| [0, 10, 20, 30].sample }
  sequence(:pricefeed_pair) { |_| %w[xau-usd eth-usd xbt-usd dai-usd xau-eth xau-dai xau-xbt].sample }
end
