# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'countries query', type: :schema do
  let(:query) do
    <<~GQL
      query($blocked: Boolean) {
        countries(blocked: $blocked) {
          name
          value
          blocked
        }
      }
    GQL
  end
  let(:context) { {} }

  specify 'should work without variables' do
    result = execute(query, {}, context)

    expect(result).to(have_no_graphql_errors)
  end

  specify 'should work with variables' do
    result = execute(query, { blocked: generate(:boolean) }, context)

    expect(result).to(have_no_graphql_errors)
  end
end
