# frozen_string_literal: true

module Resolvers
  class CountriesResolver < Types::Base::BaseResolver
    type [Types::Value::CountryType], null: false

    argument :blocked, Boolean,
             required: false,
             default_value: false,
             description: <<~EOS
               Filter countries if they are blocked.
                By default, this returns the usable or legal countries.
             EOS

    def resolve(blocked: false)
      Rails.configuration.countries
           .select { |country| country['blocked'] == blocked }
    end
  end
end
