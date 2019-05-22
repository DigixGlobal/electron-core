# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe RegisterUserMutation do
    let(:mutation) { described_class.new(object: nil, context: {}) }
    let(:params) { attributes_for(:register_user) }

    specify 'should work with valid data' do
      expect(mutation.resolve(params)).to(have_no_mutation_errors)
    end

    specify 'should fail when mailer is not working' do
      ActionMailer::Base.any_instance.stub(:mail).and_raise('ECONNREFUSED')

      expect(mutation.resolve(params)).to(have_mutation_errors)
    end

    specify 'should fail with empty data' do
      expect(mutation.resolve({})).to(have_mutation_errors)
    end
  end
end
