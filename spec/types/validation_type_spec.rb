# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe ValidationType do
    let(:field) { ElectronCoreSchema.find('Validation.isUserEmailAvailable') }
    let(:context) do
      GraphQL::Query::Context.new(
        query: GraphQL::Query.new(ElectronCoreSchema),
        values: {},
        object: { schema: ElectronCoPreSchema }
      )
    end

    context 'with isUserEmailAvailable' do
      specify 'should work with valid email' do
        expect(field.resolve({}, { email: user.email }, context)).to(be_truthy)
      end
    end
  end
end
