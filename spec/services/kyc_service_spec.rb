# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KycService, type: :service do
  describe '.register_kyc' do
    let(:user) { create(:user) }
    let(:params) { attributes_for(:register_user) }

    context 'with valid data' do
      let!(:result) { KycService.register_kyc(user.id, params) }

      specify 'should work' do
        expect(result).to(be_success)

        value = result.value!

        expect(value).to(be_instance_of(KycTypes::KycEntity))
        expect(value)
          .to(include(
                tier: eq(:tier_1.to_s),
                first_name: eq(params[:first_name]),
                last_name: eq(params[:last_name]),
                birthdate: eq(params[:birthdate]),
                citizenship: eq(params[:citizenship]),
                residence: include(
                  country: eq(params[:country_of_residence])
                )
              ))
      end

      it 'should fail with the same params' do
        expect(KycService.register_kyc(user.id, params))
          .to(has_failure_type(:kyc_already_created))
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(KycService.register_kyc(user.id, {}))
          .to(be_failure)
      end

      context 'on first name' do
        let(:key) { :first_name }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            FactoryBot.generate(:first_name)
                      .ljust(SecureRandom.random_number(151..1000), 'z')
          end.check(10) do |invalid_name|
            invalid_params = params.merge(key => invalid_name)

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on last name' do
        let(:key) { :last_name }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            FactoryBot.generate(:last_name)
                      .ljust(SecureRandom.random_number(151..1000), 'z')
          end.check(10) do |invalid_name|
            invalid_params = params.merge(key => invalid_name)

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on birthdate' do
        let(:key) { :birthdate }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when exactly of minimum age' do
          freeze_time do
            invalid_params = params.merge(
              key => (Kyc::MINIMUM_AGE.years.ago + 1.day).to_date
            )

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(:birthdate))

            valid_params = params.merge(key => Kyc::MINIMUM_AGE.years.ago.to_date)

            expect(KycService.register_kyc(user.id, valid_params))
              .to(be_success)
          end
        end

        example 'when invalid' do
          property_of { Faker::Date.birthday(1, Kyc::MINIMUM_AGE) }.check(10) do |invalid_date|
            invalid_params = params.merge(key => invalid_date)

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on country of residence' do
        let(:key) { :country_of_residence }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { SecureRandom.hex }.check(10) do |invalid_country|
            invalid_params = params.merge(key => invalid_country)

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end

        example 'when illegal country' do
          invalid_params = params.merge(key => generate(:blocked_country_value))

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on citizenship' do
        let(:key) { :citizenship }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { SecureRandom.hex }.check(10) do |invalid_country|
            invalid_params = params.merge(key => invalid_country)

            expect(KycService.register_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end

        example 'when illegal country' do
          invalid_params = params.merge(key => generate(:blocked_country_value))

          expect(KycService.register_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end

  describe '.verify_code' do
    let(:code) { generate(:verification_code) }

    context 'with valid code' do
      let(:result) { KycService.verify_code(code) }

      before do
        verification_pattern = /\A(\d+)-(\h{2})-(\h{2})\Z/i

        value = SecureRandom.random_number(1000..10_000).to_s(16)
        _block_number, first_two, last_two =
          code.match(verification_pattern).captures

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_blockNumber/)
          .to_return(body: { result: value }.to_json)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_getBlockByNumber/)
          .to_return(body: {
            result: { 'hash' => "0x#{first_two}1234#{last_two}" }
          }.to_json)
      end

      specify 'should work' do
        expect(result).to(be_success)
      end
    end

    context 'can fail' do
      example 'with invalid hash' do
        value = SecureRandom.random_number(1000..10_000).to_s(16)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_blockNumber/)
          .to_return(body: { result: value }.to_json)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_getBlockByNumber/)
          .to_return(body: {
            result: { 'hash' => value }
          }.to_json)

        expect(KycService.verify_code(code)).to(has_failure_type(:invalid_hash))
      end

      example 'with missing block' do
        value = SecureRandom.random_number(1000..10_000).to_s(16)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_blockNumber/)
          .to_return(body: { result: value }.to_json)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_getBlockByNumber/)
          .to_return(body: { error: 'BAR' }.to_json)

        expect(KycService.verify_code(code)).to(has_failure_type(:block_not_found))
      end

      example 'with delayed block' do
        max_block_delay = Rails.configuration.ethereum['max_block_delay'].to_i
        verification_pattern = /\A(\d+)-(\h{2})-(\h{2})\Z/i

        block_number, first_two, last_two =
          code.match(verification_pattern).captures

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_blockNumber/)
          .to_return(body: { result: block_number }.to_json)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_getBlockByNumber/)
          .to_return(body: {
            result: {
              'hash' => '0x1234',
              'number' => (block_number.to_i + max_block_delay + 1).to_s(16)
            }
          }.to_json)

        expect(KycService.verify_code(code))
          .to(has_failure_type(:verification_expired))

        WebMock.reset!

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_blockNumber/)
          .to_return(body: { result: block_number }.to_json)

        stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
          .with(body: /eth_getBlockByNumber/)
          .to_return(body: {
            result: {
              'hash' => "0x#{first_two}1234#{last_two}",
              'number' => (block_number.to_i + max_block_delay).to_s(16)
            }
          }.to_json)

        expect(KycService.verify_code(code)).to(be_success)
      end
    end
  end

  describe '.draft_tier2_kyc' do
    let(:user) { create(:user_with_kyc) }
    let(:params) { attributes_for(:draft_tier2_kyc) }

    context 'with valid data' do
      let!(:result) { KycService.draft_tier2_kyc(user.id, params) }

      specify 'should work' do
        expect(result).to(be_success)

        value = result.value!

        expect(value).to(be_instance_of(KycTypes::Tier2KycEntity))
        expect(value)
          .to(include(
                status: eq(:drafted.to_s),
                residence_proof_type: eq(params[:residence_proof_type]),
                residence_postal_code: eq(params[:residence_postal_code]),
                residence_line_1: eq(params[:residence_line_1]),
                residence_line_2: eq(params[:residence_line_2]),
                identification_proof_number: eq(params[:identification_proof_number]),
                identification_proof_type: eq(params[:identification_proof_type]),
                identification_proof_image: be_truthy,
                identification_proof_expiration_date:
                  eq(params[:identification_proof_expiration_date]),
                identification_pose_image: be_truthy
              ))

        expect(value.residence_proof_image[:original].data_uri.to_s)
          .to(eq(params[:residence_proof_image].to_s))
        expect(value.identification_proof_image[:original].data_uri.to_s)
          .to(eq(params[:identification_proof_image].to_s))
        expect(value.identification_pose_image[:original].data_uri.to_s)
          .to(eq(params[:identification_pose_image].to_s))
      end

      it 'should still work with the same params' do
        expect(KycService.draft_tier2_kyc(user.id, params))
          .to(be_success)
      end

      it 'should update with the different params' do
        new_params = attributes_for(:draft_tier2_kyc)

        result = KycService.draft_tier2_kyc(user.id, new_params)

        expect(result).to(be_success)

        value = result.value!

        expect(value.residence_line_1).to(eq(new_params[:residence_line_1]))
        expect(value.residence_line_1).not_to(eq(params[:residence_line_1]))
      end
    end

    context 'with submitted KYC' do
      specify 'should work when rejected' do
        rejected_kyc = create(:rejected_kyc_tier_2)

        expect(KycService.draft_tier2_kyc(rejected_kyc.user_id, params))
          .to(be_success)
      end

      specify 'should fail when approved' do
        approved_kyc = create(:approved_kyc_tier_2)

        expect(KycService.draft_tier2_kyc(approved_kyc.user_id, params))
          .to(be_failure)
      end
    end

    context 'can fail' do
      example 'with empty data' do
        expect(KycService.draft_tier2_kyc(user.id, {}))
          .to(be_failure)
      end

      example 'with invalid user' do
        expect(KycService.draft_tier2_kyc(SecureRandom.uuid, params))
          .to(be_failure)
      end

      context 'on residence proof type' do
        let(:key) { :residence_proof_type }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          invalid_params = params.merge(key => SecureRandom.hex)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on residence proof type' do
        let(:key) { :residence_proof_type }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on residence proof image' do
        let(:key) { :residence_proof_image }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on residence postal code' do
        let(:key) { :residence_postal_code }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          invalid_params = params.merge(key => SecureRandom.hex)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on residence city' do
        let(:key) { :residence_city }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            FactoryBot.generate(:city)
                      .ljust(SecureRandom.random_number(251..1000), 'z')
          end.check(10) do |invalid_city|
            invalid_params = params.merge(key => invalid_city)

            expect(KycService.draft_tier2_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on residence line 1' do
        let(:key) { :residence_line_1 }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            FactoryBot.generate(:street_address)
                      .ljust(SecureRandom.random_number(1000..10_000), 'z')
          end.check(10) do |invalid_residence|
            invalid_params = params.merge(key => invalid_residence)

            expect(KycService.draft_tier2_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on residence line 2' do
        let(:key) { :residence_line_2 }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            FactoryBot.generate(:street_address)
                      .ljust(SecureRandom.random_number(1000..10_000), 'z')
          end.check(10) do |invalid_residence|
            invalid_params = params.merge(key => invalid_residence)

            expect(KycService.draft_tier2_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on identification proof number' do
        let(:key) { :identification_proof_number }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of do
            SecureRandom.hex
                        .ljust(SecureRandom.random_number(51..100), 'z')
          end.check(10) do |invalid_number|
            invalid_params = params.merge(key => invalid_number)

            expect(KycService.draft_tier2_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on identification proof image' do
        let(:key) { :identification_proof_image }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on identification proof type' do
        let(:key) { :identification_proof_type }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          invalid_params = params.merge(key => SecureRandom.hex)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on identification proof expiration date' do
        let(:key) { :identification_proof_expiration_date }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { FactoryBot.generate(:past_date) }.check(10) do |invalid_date|
            invalid_params = params.merge(key => invalid_date)

            expect(KycService.draft_tier2_kyc(user.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on identification pose type' do
        let(:key) { :identification_pose_image }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end

      context 'on identification pose image' do
        let(:key) { :identification_pose_image }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.draft_tier2_kyc(user.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end

  describe '.submit_applying_kyc' do
    let(:user) { create(:drafted_kyc_tier_2).user }

    specify 'should work' do
      result = KycService.submit_applying_user_kyc(user.id)

      expect(result).to(be_success)
      expect(result.value!.status).to(eq(:pending.to_s))
    end

    context 'can fail' do
      example 'with missing fields' do
        kyc = user.kyc

        %i[
          form_step
          residence_proof_type
          residence_city
          residence_postal_code
          residence_line_1
          residence_line_2
          identification_proof_number
          identification_proof_type
          identification_proof_expiration_date
          residence_proof_image
          identification_pose_image
          identification_proof_image
        ].each do |key|
          ApplicationRecord.transaction do
            kyc.update_attribute(key, nil)

            expect(KycService.submit_applying_user_kyc(user.id))
              .to(has_invalid_data_error_field(key))

            raise ActiveRecord::Rollback
          end
        end
      end

      example 'with missing user' do
        expect(KycService.submit_applying_user_kyc(SecureRandom.uuid))
          .to(has_failure_type(:user_not_found))
      end

      example 'with invalid user' do
        invalid_user = create(:kyc_officer_user)

        expect(KycService.submit_applying_user_kyc(invalid_user.id))
          .to(has_failure_type(:unauthorized_action))
      end

      example 'with user without an eth address' do
        invalid_user = create(:drafted_kyc_tier_2).user
        invalid_user.update_attribute(:eth_address, nil)

        expect(KycService.submit_applying_user_kyc(invalid_user.id))
          .to(has_failure_type(:unauthorized_action))
      end

      example 'should fail if repeated' do
        expect(KycService.submit_applying_user_kyc(user.id)).to(be_success)
        expect(KycService.submit_applying_user_kyc(user.id)).to(be_failure)
      end
    end
  end

  describe '.approve_applying_kyc' do
    let(:officer) { create(:kyc_officer_user) }
    let(:kyc) { create(:pending_kyc_tier_2) }
    let(:params) { attributes_for(:approve_applying_kyc) }
    let!(:web_stub) do
      stub_request(:post, "#{KycApi::SERVER_URL}/tier2Approval")
        .to_return(body: {}.to_json)
    end

    context 'with valid data' do
      let!(:result) { KycService.approve_applying_kyc(officer.id, kyc.id, params) }

      specify 'should work' do
        expect(result).to(be_success)
        expect(result.value!)
          .to(include(
                officer_id: eq(officer.id),
                status: eq(:approving.to_s),
                expiration_date: eq(params[:expiration_date])
              ))
      end

      it 'should update KYC server' do
        expect(web_stub).to(have_been_requested)
      end

      it 'should fail with the same params' do
        expect(KycService.approve_applying_kyc(officer.id, kyc.id, params))
          .to(has_failure_type(:kyc_not_pending))
      end
    end

    context 'can fail' do
      context 'on officer' do
        example 'when it does not exist' do
          expect(KycService.approve_applying_kyc(SecureRandom.uuid, kyc.id, params))
            .to(has_failure_type(:officer_not_found))
        end

        example 'when is not a officer' do
          false_officer = create(:user)

          expect(KycService.approve_applying_kyc(false_officer.id, kyc.id, params))
            .to(has_failure_type(:unauthorized_action))
        end
      end

      example 'when kyc does not exist' do
        expect(KycService.approve_applying_kyc(officer.id, SecureRandom.uuid, params))
          .to(has_failure_type(:kyc_not_found))
      end

      example 'when data is empty' do
        expect(KycService.approve_applying_kyc(officer.id, kyc.id, {}))
          .to(has_failure_type(:invalid_data))
      end

      example 'when KYC api is down' do
        stub_request(:post, "#{KycApi::SERVER_URL}/tier2Approval")
          .to_raise(StandardError)

        expect(KycService.approve_applying_kyc(officer.id, kyc.id, params))
          .to(has_failure_type(:request_failed))
      end

      context 'on expiration date' do
        let(:key) { :expiration_date }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.approve_applying_kyc(officer.id, kyc.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { FactoryBot.generate(:past_date) }.check(10) do |invalid_date|
            invalid_params = params.merge(key => invalid_date)

            expect(KycService.approve_applying_kyc(officer.id, kyc.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end
    end
  end

  describe '.reject_applying_kyc' do
    let(:officer) { create(:kyc_officer_user) }
    let(:kyc) { create(:pending_kyc_tier_2) }
    let(:params) { attributes_for(:reject_applying_kyc) }

    context 'with valid data' do
      let!(:result) { KycService.reject_applying_kyc(officer.id, kyc.id, params) }

      specify 'should work' do
        expect(result).to(be_success)
        expect(result.value!)
          .to(include(
                officer_id: eq(officer.id),
                status: eq(:rejected.to_s),
                rejection_reason: eq(params[:rejection_reason])
              ))
      end

      it 'should fail with the same params' do
        expect(KycService.reject_applying_kyc(officer.id, kyc.id, params))
          .to(has_failure_type(:kyc_not_pending))
      end
    end

    context 'can fail' do
      context 'on officer' do
        example 'when it does not exist' do
          expect(KycService.reject_applying_kyc(SecureRandom.uuid, kyc.id, params))
            .to(has_failure_type(:officer_not_found))
        end

        example 'when is not a officer' do
          false_officer = create(:user)

          expect(KycService.reject_applying_kyc(false_officer.id, kyc.id, params))
            .to(has_failure_type(:unauthorized_action))
        end
      end

      example 'when kyc does not exist' do
        expect(KycService.reject_applying_kyc(officer.id, SecureRandom.uuid, params))
          .to(has_failure_type(:kyc_not_found))
      end

      example 'when data is empty' do
        expect(KycService.reject_applying_kyc(officer.id, kyc.id, {}))
          .to(has_failure_type(:invalid_data))
      end

      context 'on rejection reason' do
        let(:key) { :rejection_reason }

        example 'when empty' do
          invalid_params = params.merge(key => nil)

          expect(KycService.reject_applying_kyc(officer.id, kyc.id, invalid_params))
            .to(has_invalid_data_error_field(key))
        end

        example 'when invalid' do
          property_of { SecureRandom.hex }.check(10) do |invalid_reason|
            invalid_params = params.merge(key => invalid_reason)

            expect(KycService.reject_applying_kyc(officer.id, kyc.id, invalid_params))
              .to(has_invalid_data_error_field(key))
          end
        end
      end
    end
  end

  describe '.mark_kyc_approved' do
    let(:kyc) { create(:approving_kyc_tier_2) }
    let(:params) { { address: kyc.user.eth_address, txhash: generate(:txhash) } }

    context 'with valid data' do
      let!(:result) { KycService.mark_kyc_approved(params) }

      specify 'should work' do
        expect(result).to(be_success)

        value = result.value!

        expect(value)
          .to(include(
                status: :approved.to_s
              ))
      end

      it 'should fail with the same params' do
        expect(KycService.mark_kyc_approved(params))
          .to(has_failure_type(:invalid_kyc))
      end
    end

    context 'can fail' do
      example 'when data is empty' do
        expect(KycService.mark_kyc_approved({}))
          .to(has_failure_type(:invalid_data))
      end

      context 'on address' do
        let(:key) { :address }

        example 'when empty' do
          expect(KycService.mark_kyc_approved(params.merge(key => nil)))
            .to(has_invalid_data_error_field(key))
        end

        example 'when it does not exist' do
          expect(KycService.mark_kyc_approved(params.merge(key => generate(:eth_address))))
            .to(has_failure_type(:user_not_found))
        end

        example 'when it does not a pending KYC' do
          drafted_user = create(:drafted_kyc_tier_2).user

          expect(KycService.mark_kyc_approved(params.merge(key => drafted_user.eth_address)))
            .to(has_failure_type(:invalid_kyc))
        end

        example 'when invalid' do
          property_of { SecureRandom.hex }.check(10) do |invalid_address|
            expect(KycService.mark_kyc_approved(params.merge(key => invalid_address)))
              .to(has_invalid_data_error_field(key))
          end
        end
      end

      context 'on txhash' do
        let(:key) { :txhash }

        example 'when empty' do
          expect(KycService.mark_kyc_approved(params.merge(key => nil)))
            .to(has_invalid_data_error_field(key))
        end
      end
    end
  end
end
