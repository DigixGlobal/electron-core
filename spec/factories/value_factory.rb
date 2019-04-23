# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  sequence(:country_value) do |_|
    Rails.configuration.countries
         .map { |country| country['value'] }
         .sample
  end
  sequence(:unblocked_country_value) do |_|
    Rails.configuration.countries
         .filter { |country| country['blocked'] == false }
         .map { |country| country['value'] }
         .sample
  end
  sequence(:blocked_country_value) do |_|
    Rails.configuration.countries
         .filter { |country| country['blocked'] == true }
         .map { |country| country['value'] }
         .sample
  end

  sequence(:rejection_reason) do |_|
    Rails.configuration.rejection_reasons
         .map { |reason| reason['value'] }
         .sample
  end
end
