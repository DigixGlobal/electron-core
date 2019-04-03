require 'faker'

FactoryBot.define do
  sequence(:uid) { |_| SecureRandom.random_number(1_000_000) }
  sequence(:email) { |_| Faker::Internet.safe_email }
  sequence(:password) { |_| Faker::Internet.password(6, 30) }
end
