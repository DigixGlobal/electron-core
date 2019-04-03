# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe RegisterUserMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }
    let(:params) { attributes_for(:register_user) }

    specify 'should work with valid data' do
      result = mutation.resolve(params)

      expect(result).to(have_no_mutation_errors)
      expect(result[:user]).to(be_instance_of(User))
    end

    specify 'should fail with empty data' do
      expect(mutation.resolve(email: nil, password: nil))
        .to(have_mutation_errors)
    end
  end
end
