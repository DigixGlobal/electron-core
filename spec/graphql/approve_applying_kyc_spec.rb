# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'approveApplyingKyc mutation', type: :schema do
  let(:context) { { current_user: create(:kyc_officer_user) } }
  let(:kyc) { create(:pending_kyc_tier_2) }
  let(:query) do
    <<~GQL
      mutation(
        $applyingKycId: ID!,
        $expirationDate: Date!
      ) {
        approveApplyingKyc(
          input: {
            applyingKycId: $applyingKycId,
            expirationDate: $expirationDate
          }
        ) {
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

  let(:key) { 'approveApplyingKyc' }
  let(:params) { params_for(:approve_applying_kyc_params, 'applyingKycId' => kyc.id) }

  before do
    stub_request(:post, "#{KycApi::SERVER_URL}/tier2Approval")
      .to_return(body: {}.to_json)
  end

  specify 'should work with valid data' do
    result = execute(query, params, context)

    expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, {}, context)).to(have_graphql_errors(key))
  end

  specify 'should fail without a current user' do
    expect(execute(query, params)).to(have_graphql_errors(key))
  end
end
