# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'draftTier2Kyc mutation', type: :schema do
  let(:submit) { false }
  let(:context) { { current_user: create(:user_with_kyc) } }
  let(:query) do
    <<~GQL
      mutation(
        $formStep: PositiveInteger!
        $submit: Boolean
        $residenceProofImage: DataUrl
        $residenceCity: String
        $residencePostalCode: String
        $residenceLine1: String
        $residenceLine2: String
        $identificationProofNumber: String
        $identificationProofType: KycIdentificationProofTypeEnum
        $identificationProofImage: DataUrl
        $identificationProofExpirationDate: Date
        $identificationPoseImage: DataUrl
      ) {
        draftTier2Kyc(
          input: {
            formStep: $formStep
            submit: $submit
            residenceProofImage: $residenceProofImage
            residenceCity: $residenceCity
            residencePostalCode: $residencePostalCode
            residenceLine1: $residenceLine1
            residenceLine2: $residenceLine2
            identificationProofNumber: $identificationProofNumber
            identificationProofType: $identificationProofType
            identificationProofImage: $identificationProofImage
            identificationProofExpirationDate: $identificationProofExpirationDate
            identificationPoseImage: $identificationPoseImage
          }
        ) {
          errors {
            field
            message
          }
          applyingKyc {
            createdAt
            id
            formStep
            identificationPoseImage {
              original {
                contentType
                dataUrl
                uri
              }
              thumbnail {
                contentType
                dataUrl
                uri
              }
            }
            identificationProofExpirationDate
            identificationProofImage {
              original {
                contentType
                dataUrl
                uri
              }
              thumbnail {
                contentType
                dataUrl
                uri
              }
            }
            identificationProofNumber
            identificationProofType
            residenceCity
            residenceLine1
            residenceLine2
            residencePostalCode
            residenceProofImage {
              original {
                contentType
                dataUrl
                uri
              }
              thumbnail {
                contentType
                dataUrl
                uri
              }
            }
            status
            updatedAt
          }
        }
      }
    GQL
  end

  let(:key) { 'draftTier2Kyc' }

  context 'without submitting' do
    let(:submit) { false }
    specify 'should work with valid data' do
      result = execute(query, params_for(:draft_tier2_kyc_params), context)

      expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
    end

    specify 'should fail with empty data' do
      expect(execute(query, {}, context)).to(have_graphql_errors(key))
    end
  end

  context 'with submitting' do
    let(:submit) { true }
    specify 'should work with valid data' do
      result = execute(query, params_for(:draft_tier2_kyc_params), context)

      expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
    end

    specify 'should fail with empty data' do
      expect(execute(query, {}, context)).to(have_graphql_errors(key))
    end
  end

  specify 'should fail without a current user ' do
    expect(execute(query, params_for(:draft_tier2_kyc_params))).to(have_graphql_errors(key))
  end
end
