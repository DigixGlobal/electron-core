# frozen_string_literal: true

require 'rails_helper'

module Controllers
  RSpec.describe 'Kyc Processor', type: :request do
    describe 'GET /tier2Approval' do
      let(:path) { kyc_processor_approve_addresses_path }

      context 'with valid data' do
        let(:kyc) { create(:approving_kyc_tier_2) }
        let(:payload) do
          [
            {
              address: kyc.user.eth_address,
              txhash: generate(:txhash)
            },
            attributes_for(:mark_kyc_approved)
          ]
        end

        before do
          post(
            path,
            params: payload.to_json,
            headers: {
              'Authorization': AccessService.access_authorization('POST', path, payload),
              'Content-Type': 'application/json'
            }
          )
        end

        specify 'should respond correctly' do
          expect(response).to(have_http_status(:ok))
        end

        specify 'should update KYC' do
          kyc.reload

          expect(response.body).to(match(kyc.user.eth_address))
          expect(kyc.applying_status).to(eq(:approved.to_s))
        end
      end

      context 'can fail' do
        let(:payload) { [] }

        def make_request(payload, authorization = nil)
          new_authorization = authorization.nil? ?
                                 AccessService.access_authorization('POST', path, payload) :
                                 authorization

          post(
            path,
            params: payload.to_json,
            headers: {
              'Authorization': new_authorization,
              'Content-Type': 'application/json'
            }
          )
        end

        example 'when unauthorized' do
          make_request(payload, '')

          expect(response).to(have_http_status(:unauthorized))
        end

        example 'when invalid' do
          make_request({})

          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end
    end

    describe 'GET /addressChanged' do
      let(:path) { kyc_processor_confirm_changes_path }

      context 'with valid data' do
        let(:payload) { [] }

        before do
          post(
            path,
            params: payload.to_json,
            headers: {
              'Authorization': AccessService.access_authorization('POST', path, payload),
              'Content-Type': 'application/json'
            }
          )
        end

        specify 'should respond correctly' do
          expect(response).to(have_http_status(:ok))
        end
      end

      context 'can fail' do
        let(:payload) { [] }

        def make_request(payload, authorization = nil)
          new_authorization = authorization.nil? ?
                                 AccessService.access_authorization('POST', path, payload) :
                                 authorization

          post(
            path,
            params: payload.to_json,
            headers: {
              'Authorization': new_authorization,
              'Content-Type': 'application/json'
            }
          )
        end

        example 'when unauthorized' do
          make_request(payload, '')

          expect(response).to(have_http_status(:unauthorized))
        end
      end
    end
  end
end
