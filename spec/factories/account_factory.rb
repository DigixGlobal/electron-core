# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :register_user, class: 'Object' do
    email { generate(:email) }
    password { generate(:password) }
  end
end
