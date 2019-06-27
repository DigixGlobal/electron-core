# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'appUser query', type: :schema do
  let(:context) { {} }
  let(:key) { 'appUser' }
  let(:query) do
    <<~GQL
      query {
        appUser {
          country
        }
      }
    GQL
  end

  specify 'should work' do
    result = execute(query, {}, context)

    expect(result).to(have_no_graphql_errors)
  end
end
