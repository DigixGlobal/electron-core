# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe CountriesResolver, type: :resolver do
    let(:resolver) { described_class.new(object: nil, context: {}) }

    specify 'should work' do
      expect(resolver.resolve({}))
        .to(all(include(*Types::Value::CountryType.fields.keys)))
    end

    context 'blocked argument should work' do
      example 'when true' do
        blocked_countries =
          Rails.configuration.countries
               .select { |country| country['blocked'] == true }

        expect(resolver.resolve(blocked: true))
          .to(match_array(blocked_countries))
      end

      example 'when false' do
        unblocked_countries =
          Rails.configuration.countries
               .select { |country| country['blocked'] == false }

        expect(resolver.resolve(blocked: false))
          .to(match_array(unblocked_countries))
      end
    end
  end
end
