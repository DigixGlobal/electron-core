# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resetPassword mutation', type: :schema do
  let(:user) { create(:user) }
  let(:token) { user.send_reset_password_instructions }
  let(:query) do
    <<~GQL
      mutation ($token: String!, $password: String!, $passwordConfirmation: String!) {
        resetPassword(input: { token: $token, password: $password, passwordConfirmation: $passwordConfirmation }) {
          errors {
            field
            message
          }
        }
      }
    GQL
  end

  let(:key) { 'resetPassword' }

  specify 'should work with valid data' do
    result = execute(query, params_for(:reset_password_params, token: token))

    expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  context 'can fail' do
    example 'with empty data' do
      expect(execute(query, {})).to(have_graphql_errors(key))
    end
  end
end
