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

    countries = result.dig('data', 'countries')
    expect(countries.find{ |country| country["blocked"] == true }).to(be_truthy)
    expect(countries.find{ |country| country["blocked"] == false }).to(be_truthy)
  end

  specify 'should work with variables' do
    flag = generate(:boolean)
    result = execute(query, { blocked: flag }, context)

    expect(result).to(have_no_graphql_errors)

    countries = result.dig('data', 'countries')
    expect(countries).to(all(include("blocked" => eq(flag))))
  end
end
