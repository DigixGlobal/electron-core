# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'currentUser query', type: :schema do
  let(:context) { { current_user: user } }
  let(:key) { 'currentUser' }

  describe 'user type' do
    let(:user) { create(:user) }
    let(:query) do
      <<~GQL
        query {
          currentUser {
            id
            email
            ethAddress
            tncVersion
          }
        }
      GQL
    end

    specify 'should work' do
      result = execute(query, {}, context)

      expect(result).to(have_no_graphql_errors)
    end

    specify 'should fail without a current user' do
      expect(execute(query, {})).to(have_graphql_errors)
    end
  end

  describe 'kyc tier 2 type' do
    let(:user) { create(:drafted_kyc_tier_2).user }
    let(:query) do
      <<~GQL
        query {
          currentUser {
            id
            kyc {
              id
              applyingKyc {
                ... on KycTier2 {
                  id
                  identificationPoseImage {
                    original {
                      contentType
                    }
                    thumbnail {
                      contentType
                    }
                  }
                  identificationProofExpirationDate
                  identificationProofImage {
                    original {
                      contentType
                    }
                    thumbnail {
                      contentType
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
                    }
                    thumbnail {
                      contentType
                    }
                  }
                  residenceProofType
                  status
                  createdAt
                  updatedAt
                }
              }
            }
          }
        }
      GQL
    end

    specify 'should work' do
      result = execute(query, {}, context)

      expect(result).to(have_no_graphql_errors)
      expect(result['data']['currentUser']['kyc']['applyingKyc'])
        .to(include(
              'status' => 'DRAFTED'
            ))
    end
  end
end
