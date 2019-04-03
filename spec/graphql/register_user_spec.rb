# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'registerUser mutation', type: :schema do
  let(:query) do
    <<~GQL
      mutation registerUser($email: String!, $password: String!) {
        registerUser(input: {email: $email, password: $password}) {
          errors {
            field
            message
          }
          user {
            email
          }
        }
      }
    GQL
  end

  let(:key) { 'registerUser' }

  specify 'should work with valid data' do
    result = execute(query, attributes_for(:register_user))

    expect(result)
      .to(have_no_graphql_errors
            .and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, {}))
      .to(have_graphql_errors(key))
  end
end
