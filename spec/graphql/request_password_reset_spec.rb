# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requestPasswordReset mutation', type: :schema do
  let(:query) do
    <<~GQL
      mutation requestPasswordReset($email: String!) {
          requestPasswordReset(input: {email: $email}) {
          clientMutationId
          errors {
            field
            message
          }
        }
      }
    GQL
  end

  let(:key) { 'requestPasswordReset' }

  let(:user) { create(:user) }

  specify 'should work with valid data' do
    result = execute(query, email: user.email)

    expect(result)
      .to(have_no_graphql_errors
            .and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, {}))
      .to(have_graphql_errors(key))
  end
end
