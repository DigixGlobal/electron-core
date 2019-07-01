# frozen_string_literal: true

require 'rails_helper'

module Types
  module Scalar
    RSpec.describe Types::Scalar::PositiveFloat, type: :graphql_type do
      let(:scalar) { described_class }
      let(:context) { {} }

      describe '.coerce_input' do
        let(:raw_value) { generate(:positive_float).to_s }

        specify 'should work with a valid float' do
          expect(scalar.coerce_input(raw_value, context))
            .to(be_instance_of(Float))
        end

        specify 'should work with zero' do
          expect(scalar.coerce_input('0', context))
            .to(eq(0))

          expect(scalar.coerce_input('0.0', context))
            .to(eq(0))
        end

        it 'should fail with an invalid float' do
          property_of { SecureRandom.uuid }.check(10) do |raw_value|
            expect { scalar.coerce_input(raw_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end

        it 'should fail with an negative number' do
          property_of { -FactoryBot.generate(:positive_float) }.check(10) do |negative_value|
            expect { scalar.coerce_input(negative_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end
      end

      describe '.coerce_result' do
        let(:value) { generate(:positive_float) }

        specify 'should work' do
          expect(scalar.coerce_result(value, context))
            .to(be_truthy)
        end
      end
    end
  end
end
