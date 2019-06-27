# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'validation query', type: :schema do
  let(:context) { {} }
  let(:key) { 'validation' }
  let(:user) { create(:user) }

  context 'with isUserEmailAvailable' do
    def fetch_field(result)
      result.dig('data', 'validation', 'isUserEmailAvailable')
    end

    let(:query) do
      <<~GQL
        query($email: String!) {
          validation {
            isUserEmailAvailable(email: $email)
          }
        }
      GQL
    end

    specify 'should be truthy with available email' do
      result = execute(query, { email: generate(:email) }, context)

      expect(result).to(have_no_graphql_errors)
      expect(fetch_field(result)).to(be_truthy)
    end

    specify 'should be falsy work' do
      result = execute(query, { email: user.email }, context)

      expect(result).to(have_no_graphql_errors)
      expect(fetch_field(result)).to(be_falsy)
    end
  end
end
