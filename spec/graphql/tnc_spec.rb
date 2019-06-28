# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tnc query', type: :schema do
  let(:context) { {} }
  let(:key) { 'tnc' }
  let(:query) do
    <<~GQL
      query {
        tnc {
          text
          version
        }
      }
    GQL
  end

  specify 'should work' do
    result = execute(query, {}, context)

    expect(result).to(have_no_graphql_errors)
  end
end
