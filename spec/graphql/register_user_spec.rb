# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'registerUser mutation', type: :schema do
  let(:query) do
    <<~GQL
      mutation(
        $firstName: String!
        $lastName: String!
        $birthdate: Date!
        $countryOfResidence: LegalCountryValue!
        $citizenship: LegalCountryValue!
        $tncVersion: String!
        $email: String!
        $password: String!
      ) {
        registerUser(
          input: {
            firstName: $firstName
            lastName: $lastName
            birthdate: $birthdate
            countryOfResidence: $countryOfResidence
            citizenship: $citizenship
            tncVersion: $tncVersion
            email: $email
            password: $password
          }
        ) {
          errors {
            field
            message
          }
          clientMutationId
        }
      }
    GQL
  end

  let(:key) { 'registerUser' }

  specify 'should work with valid data' do
    result = execute(query, params_for(:register_user_params))

    expect(result).to(have_no_graphql_errors.and(have_no_graphql_mutation_errors(key)))
  end

  specify 'should fail with empty data' do
    expect(execute(query, {})).to(have_graphql_errors(key))
  end
end
