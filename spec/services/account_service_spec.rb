# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService, type: :mutation do
  describe '.register_user' do
    let(:params) { attributes_for(:register_user) }

    context 'with valid data' do
      let!(:result) { AccountService.register_user(params) }

      specify 'should work' do
        expect(result).to(be_a_success)
        expect(result.value[:user]).to(be_instance_of(User))

        expect(result.value[:user].email).to(eq(params[:email]))
        expect(result.value[:user].password).to(eq(params[:password]))
      end

      it 'should fail with the same params' do
        expect(AccountService.register_user(params))
          .to(fail_with(:invalid_data))
      end

      describe 'confirmation email' do
        let(:confirmation_email) { ActionMailer::Base.deliveries.last }

        specify 'should be sent' do
          expect(confirmation_email)
            .to(be_truthy)
        end

        it 'should be correct' do
          expect(confirmation_email)
            .to(deliver_to(params[:email]))
          expect(confirmation_email)
            .to(have_subject('Confirmation instructions'))
        end
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(AccountService.register_user({}))
          .to(fail_with(:invalid_data))
      end

      context 'on email' do
        example 'when invalid' do
          property_of { Faker::Internet.username }.check(10) do |invalid_email|
            invalid_params = params.merge(email: invalid_email)

            expect(AccountService.register_user(invalid_params))
              .to(fail_with(:invalid_data))
          end
        end

        example 'when too long' do
          property_of do
            long_email = Faker::Internet.email
            size = SecureRandom.random_number(255..1000)

            long_email.ljust(size, 'z')
          end.check(10) do |long_email|
            invalid_params = params.merge(email: long_email)

            expect(AccountService.register_user(invalid_params))
              .to(fail_with(:invalid_data))
          end
        end
      end

      context 'on password' do
        example 'when invalid' do
          property_of { Faker::Internet.password(1, 5) }
            .check(10) do |invalid_password|
            invalid_params = params.merge(password: invalid_password)

            expect(AccountService.register_user(invalid_params))
              .to(fail_with(:invalid_data))
          end
        end
      end
    end
  end

  describe '.confirm_user_by_token' do
    let(:user) { create(:unconfirmed_user) }
    let(:token) do
      user.send_confirmation_instructions

      user.confirmation_token
    end

    context 'with valid token' do
      let!(:result) { AccountService.confirm_user_by_token(token) }

      specify 'should work' do
        expect(result).to(be_a_success)
        expect(result.value[:user]).to(be_instance_of(User))
      end

      it 'should confirm the user' do
        user.reload
        expect(user.confirmed?).to(be(true))
      end

      it 'should fail with the same token' do
        expect(AccountService.confirm_user_by_token(token))
          .to(fail_with(:user_already_confirmed))
      end
    end

    context 'can fail' do
      example 'with invalid token' do
        expect(AccountService.confirm_user_by_token(SecureRandom.hex))
          .to(fail_with(:user_not_found))
      end
    end
  end

  describe '.request_authorization' do
    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: user.password } }

    context 'with valid credentials' do
      specify 'should work' do
        result = AccountService.request_authorization(params)

        expect(result).to(be_a_success)
        expect(result.value[:token]).to(include('accessToken', 'client', 'uid'))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        result = AccountService.request_authorization({})

        expect(result).to(fail_with(:invalid_credentials))
      end

      example 'with incorrect email' do
        result = AccountService.request_authorization(params.merge(email: generate(:email)))

        expect(result).to(fail_with(:invalid_credentials))
      end

      example 'with incorrect password' do
        result = AccountService.request_authorization(params.merge(password: generate(:password)))

        expect(result).to(fail_with(:invalid_credentials))
      end

      example 'when user is unconfirmed' do
        user = create(:unconfirmed_user)
        result = AccountService.request_authorization(email: user.email, password: user.password)

        expect(result).to(fail_with(:user_unconfirmed))
      end
    end
  end

  describe '.request_password_reset' do
    let(:user) { create(:user) }
    let(:email) { user.email }

    context 'with valid email' do
      let!(:result) { AccountService.request_password_reset(email) }

      specify 'should work' do
        expect(result).to(be_a_success)
        expect(result.value[:user]).to(be_instance_of(User))
      end

      it 'should work again with same email' do
        expect(AccountService.request_password_reset(email))
          .to(be_a_success)
      end

      describe 'password reset email' do
        let(:reset_email) { ActionMailer::Base.deliveries.last }

        specify 'should be sent' do
          expect(reset_email)
            .to(be_truthy)
        end

        it 'should be correct' do
          expect(reset_email)
            .to(deliver_to(email))
          expect(reset_email)
            .to(have_subject('Reset password instructions'))
        end
      end
    end

    context 'can fail' do
      example 'with unused email' do
        expect(AccountService.request_password_reset(generate(:email)))
          .to(fail_with(:user_not_found))
      end

      example 'with unconfirmed user email' do
        unconfirmed_user = create(:unconfirmed_user)

        expect(AccountService.request_password_reset(unconfirmed_user.email))
          .to(fail_with(:user_not_found))
      end
    end
  end

  describe '.reset_password' do
    let(:user) { create(:user) }
    let(:token) { user.send_reset_password_instructions }
    let(:password) { generate(:password) }
    let(:params) do
      {
        token: token,
        password: password,
        password_confirmation: password
      }
    end

    context 'with valid token' do
      let!(:result) { AccountService.reset_password(params) }

      specify 'should work' do
        expect(result).to(be_a_success)
        expect(result.value[:user]).to(be_instance_of(User))
      end

      context 'and updated user' do
        let(:new_user) { result.value[:user] }

        specify 'should accept the new password' do
          expect(new_user).to(be_valid_password(password))
        end

        it 'should reject the old password' do
          expect(new_user).not_to(be_valid_password(user.password))
        end
      end

      it 'should fail with the same params' do
        expect(AccountService.reset_password(params))
          .to(fail_with(:invalid_data))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        result = AccountService.reset_password({})

        expect(result)
          .to(fail_with(:invalid_data))
        expect(result.value[:errors])
          .not_to(be_empty)
      end

      context 'on token' do
        example 'with invalid token' do
          invalid_params = params.merge(token: SecureRandom.hex)
          result = AccountService.reset_password(invalid_params)

          expect(result)
            .to(fail_with(:invalid_data))
          expect(result.value[:errors][:token])
            .not_to(be_empty)
        end
      end

      context 'on password' do
        example 'with invalid password' do
          property_of { Faker::Internet.password(1, 5) }
            .check(10) do |invalid_password|
          end
        end

        example 'with invalid password confirmation' do
          invalid_params = params.merge(
            password_confirmation: SecureRandom.hex
          )

          result = AccountService.reset_password(invalid_params)

          expect(result)
            .to(fail_with(:invalid_data))
          expect(result.value[:errors][:password_confirmation])
            .not_to(be_empty)
        end
      end
    end
  end
end
