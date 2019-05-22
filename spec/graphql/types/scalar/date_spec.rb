# frozen_string_literal: true

require 'rails_helper'

module Types
  module Scalar
    RSpec.describe Types::Scalar::Date, type: :graphql_type do
      let(:scalar) { described_class }
      let(:context) { {} }

      describe '.coerce_input' do
        let(:raw_value) { generate(:date).strftime('%F') }

        specify 'should work with a valid url' do
          expect(scalar.coerce_input(raw_value, context))
            .to(be_instance_of(::Date))
        end

        it 'should fail with an invalid url' do
          property_of { SecureRandom.hex }.check(10) do |raw_value|
            expect { scalar.coerce_input(raw_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end
      end

      describe '.coerce_result' do
        let(:value) { generate(:date) }

        specify 'should work' do
          expect(scalar.coerce_result(value, context))
            .to(be_truthy)
        end
      end
    end
  end
end
