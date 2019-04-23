# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SignInMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }
    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: user.password } }

    specify 'should work with valid data' do
      result = mutation.resolve(params)

      expect(result).to(have_no_mutation_errors)
      expect(result[:authorization])
        .to(include(*Types::User::AuthorizationType.fields.keys))
    end

    context 'can fail' do
      example 'with empty data' do
        expect(mutation.resolve(email: nil, password: nil))
          .to(have_mutation_errors)
      end

      example 'with unconfirmed user' do
        user = create(:unconfirmed_user)
        result = mutation.resolve(email: user.email, password: user.password)

        expect(result)
          .to(have_mutation_errors)
      end
    end
  end
end
