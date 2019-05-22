# frozen_string_literal: true

require 'faker'

FactoryBot.define do
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
end
