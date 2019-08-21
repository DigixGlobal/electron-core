# frozen_string_literal: true

require 'rails_helper'

module Types
  module Scalar
    RSpec.describe Types::Scalar::PositiveInteger, type: :graphql_type do
      let(:scalar) { described_class }
      let(:context) { {} }

      describe '.coerce_input' do
        let(:raw_value) { generate(:positive_integer).to_s }

        specify 'should work with a valid int' do
          expect(scalar.coerce_input(raw_value, context))
            .to(be_instance_of(Integer))
        end

        specify 'should fail work with zero' do
          expect { scalar.coerce_input('0', context) }
            .to(raise_error(GraphQL::CoercionError))
        end

        it 'should fail with an invalid int' do
          property_of { SecureRandom.uuid }.check(10) do |raw_value|
            expect { scalar.coerce_input(raw_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end

        it 'should fail with an negative number' do
          property_of { -FactoryBot.generate(:positive_integer) }.check(10) do |negative_value|
            expect { scalar.coerce_input(negative_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end
      end

      describe '.coerce_result' do
        let(:value) { generate(:positive_integer) }

        specify 'should work' do
          expect(scalar.coerce_result(value, context))
            .to(be_truthy)
        end
      end
    end
  end
end
