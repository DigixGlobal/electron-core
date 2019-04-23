# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DraftTier2KycMutation do
    let(:user) { create(:user_with_kyc) }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }
    let(:params) { attributes_for(:draft_tier2_kyc) }

    specify 'should work with valid data' do
      expect(mutation.resolve(params)).to(have_no_mutation_errors)
    end

    specify 'should fail with tier 2 user' do
      user.kyc.update_attribute(:tier, :tier_2)

      expect(mutation.resolve(params)).to(have_mutation_errors)
    end

    specify 'should fail with empty data' do
      expect(mutation.resolve({})).to(have_mutation_errors)
    end
  end
end
