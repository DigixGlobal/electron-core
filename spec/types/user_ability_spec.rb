# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountTypes::UserEntity do
  let(:ability) { Ability.new(AccountTypes::UserEntity.from_model(user)) }

  context 'with an unconfirmed user' do
    let(:user) { create(:unconfirmed_user) }

    example 'cannot draft a KYC' do
      expect(ability).to_not(be_able_to(:draft, KycTypes::Tier2KycEntity))
    end
  end

  context 'with an tier 1 user' do
    let(:user) { create(:user_with_kyc) }

    describe 'draft a KYC' do
      specify 'should be allowed' do
        expect(ability).to(be_able_to(:draft, KycTypes::Tier2KycEntity))
      end

      it 'should be allowed even when user has already drafted' do
        user.kyc.update_attribute(:applying_status, :drafted)

        expect(ability).to(be_able_to(:draft, KycTypes::Tier2KycEntity))
      end

      it 'should not be allowed when submitted or no longer drafted or rejected' do
        uneditable_statuses = Kyc.applying_statuses.keys - [:drafted.to_s, :rejected.to_s]
        user.kyc.update_attribute(:applying_status, uneditable_statuses.sample)

        expect(ability).not_to(be_able_to(:draft, KycTypes::Tier2KycEntity))
      end

      it 'should not be allowed when user is no longer tier 1' do
        higher_tiers = [:tier_2]
        user.kyc.update_attribute(:tier, higher_tiers.sample)

        expect(ability).not_to(be_able_to(:draft, KycTypes::Tier2KycEntity))
      end
    end
  end

  context 'with a tier 2 user' do
    let(:user) { create(:kyc_tier_2).user }

    describe 'submit an applying KYC' do
      let(:user) { create(:drafted_kyc_tier_2).user }

      specify 'should be allowed' do
        expect(ability).to(be_able_to(:submit, KycTypes::KycEntity))
      end

      it 'should not be allowed without a drafted KYC' do
        uneditable_statuses = Kyc.applying_statuses.keys - ['drafted']
        user.kyc.update_attribute(:applying_status, uneditable_statuses.sample)

        expect(ability).not_to(be_able_to(:submit, KycTypes::KycEntity))
      end
    end
  end

  context 'with a kyc officer' do
    let(:user) { create(:kyc_officer_user) }

    describe 'approve/reject pending KYC' do
      let(:kyc) { create(:pending_kyc_tier_2) }
      let(:entity) { KycTypes::Tier2KycEntity.from_model(kyc) }

      specify 'should be allowed' do
        expect(ability).to(be_able_to(:approve, entity))
        expect(ability).to(be_able_to(:reject, entity))
      end

      specify 'should not be allowed when KYC is not pending' do
        kyc.update_attribute(:applying_status, :approving)

        expect(ability).not_to(be_able_to(:approve, entity))
        expect(ability).not_to(be_able_to(:reject, entity))
      end
    end
  end
end
