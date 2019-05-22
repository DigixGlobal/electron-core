# frozen_string_literal: true

require 'rails_helper'

module Controllers
  RSpec.describe 'User confirmation', type: :request do
    describe 'GET /accounts/confirmation' do
      context 'with unconfirmed user confirmation' do
        let(:user) { create(:unconfirmed_user) }

        before { get(user_confirmation_path(confirmation_token: user.confirmation_token)) }

        specify 'should work' do
          expect(response).to(have_http_status(:ok))
        end
      end

      context 'can fail' do
        example 'with blank token' do
          get(user_confirmation_path(confirmation_token: ''))

          expect(response).to(have_http_status(:unprocessable_entity))
        end

        example 'with invalid token' do
          get(user_confirmation_path(confirmation_token: SecureRandom.random_number))

          expect(response).to(have_http_status(:unprocessable_entity))
        end

        example 'with confirmed token' do
          user = create(:user)

          get(user_confirmation_path(confirmation_token: user.confirmation_token))

          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end
    end
  end
end
