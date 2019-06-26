# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe AppUserResolver, type: :resolver do
    let(:user) { create(:user) }
    let(:context) { { ip_address: generate(:ip_address) } }
    let(:resolver) { described_class.new(object: nil, context: context) }

    specify 'should work' do
      expect(resolver.resolve)
        .to(all(include(*Types::User::AppUserType.fields.keys.map(&:to_sym))))
    end

    context 'with country field' do
      specify 'should have value with valid IP' do
        resolver = described_class.new(object: nil, context: { ip_address: generate(:ip_address) })

        expect(resolver.resolve).to(include(country: be_truthy))
      end

      specify 'should be empty with private IP' do
        resolver = described_class.new(object: nil, context: { ip_address: generate(:private_ip_address) })

        expect(resolver.resolve).to(include(country: be_nil))
      end

      specify 'should be empty without context' do
        resolver = described_class.new(object: nil, context: { ip_address: SecureRandom.hex })

        expect(resolver.resolve).to(include(country: be_nil))
      end

      specify 'should be empty without context' do
        resolver = described_class.new(object: nil, context: {})

        expect(resolver.resolve).to(include(country: be_nil))
      end
    end
  end
end
