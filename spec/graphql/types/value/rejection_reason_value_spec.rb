# frozen_string_literal: true

require 'rails_helper'

module Types
  module Value
    RSpec.describe RejectionReasonValue, type: :graphql_type do
      let(:scalar) { described_class }
      let(:context) { {} }

      describe '.coerce_input' do
        let(:raw_value) { generate(:rejection_reason) }

        specify 'should work with a valid value' do
          expect(scalar.coerce_input(raw_value, context))
            .to(be(raw_value))
        end

        it 'should fail with an invalid value' do
          property_of { SecureRandom.hex }.check(10) do |raw_value|
            expect { scalar.coerce_input(raw_value, context) }
              .to(raise_error(GraphQL::CoercionError))
          end
        end
      end

      describe '.coerce_result' do
        let(:value) { generate(:rejection_reason) }

        specify 'should work' do
          expect(scalar.coerce_result(value, context))
            .to(be_truthy)
        end
      end
    end
  end
end
