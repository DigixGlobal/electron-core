# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe RequestPasswordResetMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }

    let(:user) { create(:user) }
    let(:email) { user.email }

    specify 'should work with valid data' do
      result = mutation.resolve(email: user.email)

      expect(result)
        .to(have_no_mutation_errors)
    end

    specify 'should fail with empty data' do
      expect(mutation.resolve(email: nil))
        .to(have_mutation_errors)
    end
  end
end
