# frozen_string_literal: true

require 'rails_helper'

module Controllers
  RSpec.describe 'User confirmation', type: :request do
    def redirect_path(error)
      "#{Users::ConfirmationsController::CONFIRMATION_URI}?error=#{error}"
    end

    describe 'GET /accounts/confirmation' do
      context 'with unconfirmed user confirmation' do
        let(:user) { create(:unconfirmed_user) }

        before { get(user_confirmation_path(confirmation_token: user.confirmation_token)) }

        specify 'should work' do
          expect(response)
            .to(redirect_to(redirect_path('')))
        end
      end

      context 'can fail' do
        example 'with blank token' do
          get(user_confirmation_path(confirmation_token: ''))

          expect(response)
            .to(redirect_to(redirect_path('user_not_found')))
        end

        example 'with invalid token' do
          get(user_confirmation_path(confirmation_token: SecureRandom.random_number))

          expect(response)
            .to(redirect_to(redirect_path('user_not_found')))
        end

        example 'with confirmed token' do
          user = create(:unconfirmed_user)

          get(user_confirmation_path(confirmation_token: user.confirmation_token))
          get(user_confirmation_path(confirmation_token: user.confirmation_token))

          expect(response)
            .to(redirect_to(redirect_path('user_already_confirmed')))
        end
      end
    end
  end
end
