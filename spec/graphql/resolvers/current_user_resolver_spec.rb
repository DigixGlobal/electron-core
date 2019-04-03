# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe CurrentUserResolver, type: :resolver do
    let(:user) { create(:user) }
    let(:resolver) { described_class.new(object: nil, context: context) }

    context 'with a current user' do
      let(:context) { { current_user: user } }

      specify 'should work' do
        expect(resolver.resolve).to(be_instance_of(User))
      end
    end

    context 'without a current user' do
      let(:context) { {} }

      specify 'should fail' do
        expect(resolver.resolve).to(be_nil)
      end
    end
  end
end
