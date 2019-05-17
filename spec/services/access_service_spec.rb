# frozen_string_literal: true

require 'rails_helper'

class TestRequest < SupportTypes::Struct
  attribute(:method, Types::String)
  attribute(:original_fullpath, Types::String)
  attribute(:raw_post, Types::String)
  attribute(:headers, Types::Hash)

  def method
    'POST'
  end
end

RSpec.describe AccessService, type: :controller do
  describe '.check_authorization' do
    context 'valid request' do
      let(:nonce) { AccessService.current_nonce }
      let(:payload) { SecureRandom.hex }
      let(:path) { "/#{SecureRandom.hex}" }
      let(:request) do
        TestRequest.new(
          method: 'POST',
          original_fullpath: path,
          raw_post: payload.to_json,
          headers: { 'Authorization' => AccessService.access_authorization('POST', path, payload) }
        )
      end
      let!(:result) { AccessService.check_authorization(request) }

      specify 'should work' do
        expect(result).to(be_success)
      end

      it 'should increase nonce' do
        expect(AccessService.current_nonce).to(be >= nonce)
      end

      it 'should fail with the same authorization' do
        expect(AccessService.check_authorization(request))
          .to(has_invalid_data_error_field(:access_nonce))
      end
    end

    context 'can fail' do
      let(:payload) { SecureRandom.hex }
      let(:path) { "/#{SecureRandom.hex}" }

      def make_auth_request(authorization)
        TestRequest.new(
          method: 'POST',
          original_fullpath: path,
          raw_post: payload.to_json,
          headers: { 'Authorization': authorization }
        )
      end

      context 'on header' do
        example 'when empty' do
          expect(
            AccessService.check_authorization(
              TestRequest.new(
                method: 'POST',
                original_fullpath: path,
                raw_post: payload.to_json,
                headers: {}
              )
            )
          ).to(has_failure_type(:invalid_data))
        end

        example 'when invalid' do
          expect(
            AccessService.check_authorization(
              TestRequest.new(
                method: 'POST',
                original_fullpath: path,
                raw_post: payload.to_json,
                headers: { 'Authorization': SecureRandom.hex }
              )
            )
          ).to(has_failure_type(:invalid_data))
        end
      end

      context 'on access-token' do
        let(:key) { :access_token }

        example 'when empty' do
          request = make_auth_request("access-nonce='N', access-sign='S'")

          expect(AccessService.check_authorization(request))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on access-nonce' do
        let(:key) { :access_nonce }

        example 'when empty' do
          request = make_auth_request("access-token='T', access-sign='S'")

          expect(AccessService.check_authorization(request))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          request = make_auth_request("access-token='T', access-nonce='#{SecureRandom.hex}' access-sign='S'")

          expect(AccessService.check_authorization(request))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on access-signature' do
        let(:key) { :access_sign }

        example 'when empty' do
          request = make_auth_request("access-token='T', access-nonce='N'")

          expect(AccessService.check_authorization(request))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          request = make_auth_request("access-token='T', access-nonce='N' access-sign='#{SecureRandom.hex}'")

          expect(AccessService.check_authorization(request))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end
end
