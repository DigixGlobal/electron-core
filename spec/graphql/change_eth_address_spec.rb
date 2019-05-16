# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'changeEthAddress mutation', type: :schema do
  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:query) do
    <<~GQL
      mutation changeEthAddress($ethAddress: String!) {
        changeEthAddress(input: {ethAddress: $ethAddress}) {
          clientMutationId
          ethAddressChange {
            ethAddress
            status
          }
          errors {
            field
            message
          }
        }
      }
    GQL
  end

  let(:key) { 'changeEthAddress' }
  let(:eth_address) { generate(:eth_address) }

  before do
    stub_request(:post, "#{KycApi::SERVER_URL}/addressChange")
      .to_return(body: {}.to_json)
  end

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
