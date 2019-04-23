# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SubmitApplyingKycMutation do
    let(:user) { create(:drafted_kyc_tier_2).user }
    let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }

    specify 'should work' do
      expect(mutation.resolve).to(have_no_mutation_errors)
    end

    it 'should fail if repeated' do
      expect(mutation.resolve).to(have_no_mutation_errors)
      expect(mutation.resolve).to(have_mutation_errors)
    end
  end
end
