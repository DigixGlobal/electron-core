# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'currentUser query', type: :schema do
  let(:query) do
    <<~GQL
      query {
        currentUser {
          email
        }
      }
    GQL
  end
  let(:key) { 'currentUser' }

  specify 'should work' do
    result = execute(query, {}, current_user: create(:user))

    expect(result)
      .to(have_no_graphql_errors
            .and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail without a current user' do
    expect(execute(query, {}))
      .to(have_graphql_errors)
  end
end
