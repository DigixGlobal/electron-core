# frozen_string_literal: true

require 'rails_helper'

module Types
  module Scalar
    RSpec.describe Types::Scalar::EthAddress, type: :graphql_type do
      let(:scalar) { described_class }
      let(:context) { {} }

      describe '.coerce_input' do
        let(:raw_value) { generate(:eth_address) }

        specify 'should work with a valid address' do
          expect(scalar.coerce_input(raw_value, context))
            .to(be_instance_of(String))
        end

        it 'should fail with an invalid address' do
          property_of { SecureRandom.hex }.check(10) do |raw_value|
            expect { scalar.coerce_input(raw_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end
      end

      describe '.coerce_result' do
        let(:value) { generate(:eth_address) }

        specify 'should work' do
          expect(scalar.coerce_result(value, context))
            .to(be_truthy)
        end
      end
    end
  end
end
