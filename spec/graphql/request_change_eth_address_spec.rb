# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requestChangeEthAddress mutation', type: :schema do
  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:query) do
    <<~GQL
      mutation ($ethAddress: String!) {
        requestChangeEthAddress(input: {ethAddress: $ethAddress}) {
          clientMutationId
          ethAddressChange {
            ethAddress
          }
          errors {
            field
            message
          }
        }
      }
    GQL
  end

  let(:key) { 'requestChangeEthAddress' }
  let(:eth_address) { generate(:eth_address) }

  specify 'should work with valid data' do
    result = execute(query, { 'ethAddress' => eth_address }, context)

    expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, nil, context)).to(have_graphql_errors(key))
  end

  specify 'should fail without a current user' do
    expect(execute(query, nil, {})).to(have_graphql_errors(key))
  end
end
