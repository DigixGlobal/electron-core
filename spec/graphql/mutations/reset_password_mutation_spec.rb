# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe ResetPasswordMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }

    let(:user) { create(:user) }

    specify 'should work with valid data' do
      result = mutation.resolve(attributes_for(:reset_password, token: user.send_reset_password_instructions))

      expect(result)
        .to(have_no_mutation_errors)
    end

    specify 'should fail with empty data' do
      expect(mutation.resolve(
               token: nil,
               password: nil,
               password_confirmation: nil
             ))
        .to(have_mutation_errors)
    end
  end
end
