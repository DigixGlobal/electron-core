# frozen_string_literal: true

require 'rails_helper'

module Controllers
  RSpec.describe 'Account', type: :request do
    describe 'GET /ethAddressChange' do
      def redirect_path(error)
        "#{AccountController::CHANGE_ETH_ADDRESS_URI}?error=#{error}"
      end

      let(:user) { create(:user) }
      let(:path) { account_change_eth_address_path }
      let(:token) do
        AccountService.request_change_eth_address(user.id, generate(:eth_address))

        user.reload.change_eth_address_token
      end
      let!(:web_stub) do
        stub_request(:post, "#{KycApi::SERVER_URL}/addressChange")
          .to_return(body: {}.to_json)
      end

      context 'with valid token' do
        before do
          get(
            path,
            params: { token: token }
          )
        end

        specify 'should respond correctly' do
          expect(response).to(redirect_to(redirect_path('')))
        end

        specify 'KYC processor should be updated' do
          expect(web_stub).to(have_been_requested)
        end
      end

      context 'can fail' do
        def make_request(token)
          get(
            path,
            params: { token: token }
          )
        end

        example 'with blank token' do
          make_request(nil)

          expect(response)
            .to(redirect_to(redirect_path('token_not_found')))
        end

        example 'with used token' do
          make_request(token)

          expect(response)
            .to(redirect_to(redirect_path('')))

          make_request(token)

          expect(response)
            .to(redirect_to(redirect_path('token_not_found')))
        end

        example 'with API down' do
          WebMock.reset!
          make_request(token)

          expect(response)
            .to(redirect_to(redirect_path('request_failed')))
        end
      end
    end
  end
end
