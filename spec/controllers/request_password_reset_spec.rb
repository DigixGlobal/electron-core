# frozen_string_literal: true

require 'rails_helper'

module Controllers
  RSpec.describe 'Request password reset', type: :request do
    PORTAL_URI = ENV.fetch('PORTAL_URI') { 'http://localhost:5000' }

    def redirect_path(token, error)
      "#{PORTAL_URI}?reset_password_token=#{token}&error=#{error}"
    end

    describe 'GET /accounts/password/edit ' do
      let(:user) { create(:user) }
      let!(:token) { user.send_reset_password_instructions }

      context 'with valid user' do
        before { get(edit_user_password_path(reset_password_token: token)) }

        specify 'should work' do
          expect(response)
            .to(redirect_to(redirect_path(token, '')))
        end
      end

      context 'can fail' do
        example 'with empty token' do
          get(edit_user_password_path(reset_password_token: ''))

          expect(response)
            .to(redirect_to(redirect_path('', 'user_not_found')))
        end

        example 'with expired token' do
          travel User.reset_password_within + 1.seconds do
            get(edit_user_password_path(reset_password_token: token))
          end

          expect(response)
            .to(redirect_to(redirect_path(token, 'token_expired')))
        end
      end
    end
  end
end
