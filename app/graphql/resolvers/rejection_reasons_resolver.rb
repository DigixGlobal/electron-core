# frozen_string_literal: true

module Resolvers
  class RejectionReasonsResolver < Types::Base::BaseResolver
    type [Types::Value::RejectionReasonType], null: false

    def resolve
      Rails.configuration.rejection_reasons
    end
  end
end
