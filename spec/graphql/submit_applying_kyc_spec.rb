# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'submitApplyingKyc mutation', type: :schema do
  let(:context) { { current_user: create(:drafted_kyc_tier_2).user } }
  let(:query) do
    <<~GQL
      mutation {
        submitApplyingKyc(input: {}) {
          errors {
            field
            message
          }
          applyingKyc {
            ... on KycTier2 {
              id
              status
            }
          }
          clientMutationId
        }
      }

    GQL
  end

  let(:key) { 'submitApplyingKyc' }

  specify 'should work' do
    result = execute(query, nil, context)

    expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail without a current user' do
    expect(execute(query, nil, {})).to(have_graphql_errors(key))
  end
end
