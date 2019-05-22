# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe RejectionReasonsResolver, type: :resolver do
    let(:resolver) { described_class.new(object: nil, context: {}) }

    specify 'should work' do
      expect(resolver.resolve)
        .to(all(include(*Types::Value::RejectionReasonType.fields.keys)))
    end
  end
end
