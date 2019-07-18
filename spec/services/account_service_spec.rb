# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService, type: :service do
  describe '.register_user' do
    let(:params) { attributes_for(:register_user) }

    context 'with valid data' do
      let!(:result) { AccountService.register_user(params) }

      specify 'should work' do
        expect(result).to(be_success)

        value = result.value!

        expect(value).to(be_instance_of(AccountTypes::UserEntity))
        expect(value)
          .to(include(
                email: eq(params[:email]),
                tnc_version: eq(params[:tnc_version])
              ))
      end

      it 'should fail with the same params' do
        expect(AccountService.register_user(params))
          .to(be_failure)
      end

      describe 'confirmation email' do
        let(:confirmation_email) { ActionMailer::Base.deliveries.last }

        specify 'should be sent' do
          expect(confirmation_email).to(be_truthy)
        end

        it 'should be correct' do
          expect(confirmation_email).to(deliver_to(params[:email]))
          expect(confirmation_email).to(have_subject('Confirmation instructions'))
        end
      end

      describe 'kyc' do
        let(:user) { result.value! }
        let(:kyc) { KycService.find_by_user(user.id) }

        specify 'should exist' do
          expect(kyc).to(be_instance_of(KycTypes::KycEntity))
        end
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(AccountService.register_user({}))
          .to(has_failure_type(:invalid_data))
      end

      context 'on email' do
        let(:key) { :email }

        example 'when failed to send' do
          ActionMailer::Base.any_instance.stub(:mail).and_raise('ECONNREFUSED')

          result = AccountService.register_user(attributes_for(:register_user))

          expect(result).to(has_failure_type(:email_not_sent))
        end

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.register_user(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            choose(
              [1, ->(_) { Faker::Internet.username }],
              [1, lambda { |_|
                    FactoryBot.generate(:email)
                              .ljust(SecureRandom.random_number(255..1000), 'z')
                  }]
            )
          end.check(10) do |invalid_email|
            invalid_params = params.merge(key => invalid_email)

            expect(AccountService.register_user(invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on password' do
        let(:key) { :password }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.register_user(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { Faker::Internet.password(1, 5) }
            .check(10) do |invalid_password|
            invalid_params = params.merge(key => invalid_password)

            expect(AccountService.register_user(invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on terms and conditions version' do
        let(:key) { :tnc_version }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.register_user(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            SecureRandom.hex.ljust(SecureRandom.random_number(51..100), 'z')
          end.check(10) do |invalid_version|
            invalid_params = params.merge(key => invalid_version)

            expect(AccountService.register_user(invalid_params))
              .to(has_invalid_data_error_field(key))
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
        expect(result).to(be_success)
        expect(result.value!).to(be_instance_of(AccountTypes::UserEntity))
      end

      it 'should confirm the user' do
        user.reload
        expect(user.confirmed?).to(be(true))
      end

      it 'should fail with the same token' do
        expect(AccountService.confirm_user_by_token(token))
          .to(has_failure_type(:user_already_confirmed))
      end
    end

    context 'can fail' do
      example 'with invalid token' do
        expect(AccountService.confirm_user_by_token(SecureRandom.hex))
          .to(has_failure_type(:user_not_found))
      end
    end
  end

  describe '.request_authorization' do
    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: user.password } }

    context 'with valid credentials' do
      specify 'should work' do
        result = AccountService.request_authorization(params)

        expect(result).to(be_success)
        expect(result.value!).to(include('accessToken', 'client', 'uid'))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(AccountService.request_authorization({}))
          .to(has_failure_type(:invalid_credentials))
      end

      example 'with incorrect email' do
        expect(AccountService.request_authorization(params.merge(email: generate(:email))))
          .to(has_failure_type(:invalid_credentials))
      end

      example 'with incorrect password' do
        expect(AccountService.request_authorization(params.merge(password: generate(:password))))
          .to(has_failure_type(:invalid_credentials))
      end

      example 'with unconfirmed user' do
        user = create(:unconfirmed_user)

        expect(AccountService.request_authorization(email: user.email, password: user.password))
          .to(has_failure_type(:user_unconfirmed))
      end
    end
  end

  describe '.request_password_reset' do
    let(:user) { create(:user) }
    let(:email) { user.email }

    context 'with valid email' do
      let!(:result) { AccountService.request_password_reset(email) }

      specify 'should work' do
        expect(result).to(be_success)
        expect(result.value!).to(be_instance_of(AccountTypes::UserEntity))
      end

      it 'should work again with same email' do
        expect(AccountService.request_password_reset(email))
          .to(be_success)
      end

      describe 'password reset email' do
        let(:reset_email) { ActionMailer::Base.deliveries.last }

        specify 'should be sent' do
          expect(reset_email).to(be_truthy)
        end

        it 'should be correct' do
          expect(reset_email).to(deliver_to(email))
          expect(reset_email).to(have_subject('Reset password instructions'))
        end
      end
    end

    context 'can fail' do
      example 'with unused email' do
        expect(AccountService.request_password_reset(generate(:email)))
          .to(has_failure_type(:user_not_found))
      end

      example 'with unconfirmed user email' do
        unconfirmed_user = create(:unconfirmed_user)

        expect(AccountService.request_password_reset(unconfirmed_user.email))
          .to(has_failure_type(:user_not_found))
      end

      example 'when email failed to send' do
        ActionMailer::Base.any_instance.stub(:mail).and_raise('ECONNREFUSED')

        unconfirmed_user = create(:user)

        expect(AccountService.request_password_reset(unconfirmed_user.email))
          .to(has_failure_type(:email_not_sent))
      end
    end
  end

  describe '.reset_password' do
    let(:user) { create(:user) }
    let(:token) { user.send_reset_password_instructions }
    let(:password) { generate(:password) }
    let!(:params) do
      {
        token: token,
        password: password,
        password_confirmation: password
      }
    end

    before do
      SecureRandom.random_number(1..5).times do
        user.create_new_auth_token
      end
    end

    context 'with valid token' do
      let!(:result) { AccountService.reset_password(params) }

      specify 'should work' do
        expect(result).to(be_success)
        expect(result.value!).to(be_instance_of(AccountTypes::UserEntity))
      end

      specify 'should work even if password notification email is not sent' do
        ActionMailer::Base.any_instance.stub(:mail).and_raise('ECONNREFUSED')

        expect(result).to(be_success)
      end

      specify 'should expire tokens' do
        expect(result).to(be_success)

        user.tokens.each do |_client, token|
          expect(Time.zone.at(token ['expiry']) > Time.zone.now).to(be_truthy)
        end
      end

      describe 'updated user' do
        let(:new_user) { User.find(result.value!.id) }

        specify 'should accept the new password' do
          expect(new_user).to(be_valid_password(password))
        end

        it 'should reject the old password' do
          expect(new_user).not_to(be_valid_password(user.password))
        end
      end

      describe 'confirmation email' do
        let(:notification_email) { ActionMailer::Base.deliveries.last }

        specify 'should be sent' do
          expect(notification_email).to(be_truthy)
        end

        it 'should be correct' do
          expect(notification_email).to(deliver_to(user.email))
          expect(notification_email).to(have_subject('Password Changed'))
        end
      end

      it 'should fail with the same params' do
        expect(AccountService.reset_password(params))
          .to(has_failure_type(:invalid_data))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        result = AccountService.reset_password({})

        expect(result).to(has_failure_type(:invalid_data))
      end

      context 'on token' do
        let(:key) { :token }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.reset_password(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          invalid_params = params.merge(key => SecureRandom.hex)

          expect(AccountService.reset_password(invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on password' do
        let(:key) { :password }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.reset_password(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            choose(Faker::Internet.password(1, 5), Faker::Internet.password(129, 1000))
          end.check(10) do |invalid_password|
            invalid_params = params.merge(key => invalid_password)

            expect(AccountService.reset_password(invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on password confirmation' do
        let(:key) { :password_confirmation }
        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(AccountService.reset_password(invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          invalid_params = params.merge(key => SecureRandom.hex)

          expect(AccountService.reset_password(invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end

  describe '.change_eth_address' do
    let(:user) { create(:user) }
    let(:eth_address) { generate(:eth_address) }
    let!(:web_stub) do
      stub_request(:post, "#{KycApi::SERVER_URL}/addressChange")
        .to_return(body: {}.to_json)
    end

    context 'with valid eth address' do
      let!(:result) { AccountService.change_eth_address(user.id, eth_address) }

      specify 'should work' do
        expect(result).to(be_success)

        value = result.value!

        expect(value).to(be_instance_of(AccountTypes::EthAddressChangeEntity))
        expect(value)
          .to(include(
                eth_address: eq(eth_address),
                status: eq(:pending.to_s)
              ))
      end

      it 'should update KYC server' do
        expect(web_stub).to(have_been_requested)
      end

      it 'should fail with the same eth address' do
        expect(AccountService.change_eth_address(user.id, eth_address))
          .to(has_failure_type(:invalid_data))
      end
    end

    context 'can fail' do
      example 'when user is missing' do
        expect(AccountService.change_eth_address(SecureRandom.uuid, eth_address))
          .to(has_failure_type(:user_not_found))
      end

      example 'when user is invalid' do
        invalid_user = create(:kyc_officer_user)

        expect(AccountService.change_eth_address(invalid_user.id, eth_address))
          .to(has_failure_type(:unauthorized_action))
      end

      example 'with empty data' do
        result = AccountService.reset_password({})

        expect(result).to(has_failure_type(:invalid_data))
      end

      example 'when KYC api is down' do
        stub_request(:post, "#{KycApi::SERVER_URL}/addressChange")
          .to_raise(StandardError)

        expect(AccountService.change_eth_address(user.id, eth_address))
          .to(has_failure_type(:request_failed))
      end

      context 'on eth address' do
        let(:key) { :eth_address }

        example 'when empty' do
          expect(AccountService.change_eth_address(user.id, nil))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { SecureRandom.hex }.check(10) do |invalid_address|
            expect(AccountService.change_eth_address(user.id, invalid_address))
              .to(has_invalid_data_error_field(key))
          end
        end

        example 'when existing address' do
          used_address = create_list(:user, 3).sample.eth_address

          expect(AccountService.change_eth_address(user.id, used_address))
            .to(has_invalid_data_error_field(key))
        end

        example 'when existing change address' do
          used_address = create(:user, new_eth_address: eth_address).new_eth_address

          expect(AccountService.change_eth_address(user.id, used_address))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end
end
