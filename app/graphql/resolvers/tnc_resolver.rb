# frozen_string_literal: true

require 'faker'

module Resolvers
  class TncResolver < Types::Base::BaseResolver
    type Types::Tnc::TncType, null: false

    def resolve
      {
        version: ENV.fetch('TNC_VERSION') { '1.0.0' },
        text: Faker::Lorem.paragraph(100, true)
      }
    end
  end
end
