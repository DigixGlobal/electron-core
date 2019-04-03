# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe ResetPasswordMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }

    let(:user) { create(:user) }

    specify 'should work with valid data' do
      token = user.send_reset_password_instructions
      password = generate(:password)

      result = mutation.resolve(
        token: token,
        password: password,
        password_confirmation: password
      )

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
