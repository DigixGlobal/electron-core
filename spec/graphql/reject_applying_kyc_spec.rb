# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rejectApplyingKyc mutation', type: :schema do
  let(:context) { { current_user: create(:kyc_officer_user) } }
  let(:kyc) { create(:pending_kyc_tier_2) }
  let(:query) do
    <<~GQL
      mutation(
        $applyingKycId: ID!,
        $rejectionReason: RejectionReasonValue!
      ) {
        rejectApplyingKyc(
          input: {
            applyingKycId: $applyingKycId,
            rejectionReason: $rejectionReason
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

  let(:key) { 'rejectApplyingKyc' }
  let(:params) { params_for(:reject_applying_kyc_params, 'applyingKycId' => kyc.id) }

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
