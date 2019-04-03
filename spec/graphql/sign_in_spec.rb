# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'signIn mutation', type: :schema do
  let(:query) do
    <<~GQL
      mutation signIn($email: String!, $password: String!) {
        signIn(input: {email: $email, password: $password}) {
          errors {
            field
            message
          }
          authorization {
            accessToken
            client
            expiry
            tokenType
            uid
          }
        }
      }
    GQL
  end

  let(:key) { 'signIn' }

  let(:user) { create(:user) }

  specify 'should work with valid data' do
    result = execute(query,
                     email: user.email,
                     password: user.password)

    expect(result)
      .to(have_no_graphql_errors
            .and(have_no_graphql_mutation_errors(key)))
  end

  context 'can fail' do
    example 'with empty data' do
      expect(execute(query, {}))
        .to(have_graphql_errors(key))
    end
  end
end
