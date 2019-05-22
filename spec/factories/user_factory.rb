# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :group, class: 'Group' do
    name { |_| Group.groups.keys.sample }

    factory :kyc_officer_group do
      name { |_| Group.groups[:kyc_officer] }
    end
  end

  factory :user, class: 'User' do
    uid { generate(:uid) }
    email { generate(:email) }
    password { generate(:password) }
    eth_address { generate(:eth_address) }
    tnc_version { generate(:version) }
    confirmed_at { DateTime.now }

    factory :user_with_kyc do
      after(:create) do |user|
        create(:kyc, user_id: user.id, tier: :tier_1)
      end
    end

    factory :kyc_officer_user do
      after(:create) do |user|
        unless (group = Group.find_by(name: Group.groups[:kyc_officer]))
          group = create(:kyc_officer_group)
        end

        user.groups << group
      end
    end

    factory :unconfirmed_user do
      before(:create) do |user|
        user.confirmed_at = nil
      end
    end
  end
end
