# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user, class: 'User' do
    uid { generate(:uid) }
    email { generate(:email) }
    password { generate(:password) }
    confirmed_at { DateTime.now }

    factory :unconfirmed_user do
      before(:create) do |user|
        user.confirmed_at = nil
      end
    end
  end
end
