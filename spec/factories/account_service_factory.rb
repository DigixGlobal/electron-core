# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :register_user, class: 'Hash' do
    first_name { generate(:first_name) }
    last_name { generate(:first_name) }
    birthdate { generate(:birthdate) }
    citizenship { generate(:unblocked_country_value) }
    country_of_residence { generate(:unblocked_country_value) }
    tnc_version { generate(:version) }
    email { generate(:email) }
    password { generate(:password) }

    factory :register_user_params do
      birthdate { generate(:birthdate).to_s }
    end
  end

  factory :reset_password, class: 'Hash' do
    token { nil }
    password { generate(:password) }
    password_confirmation { password }

    factory :reset_password_params do
    end
  end
end
