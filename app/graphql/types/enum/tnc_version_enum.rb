# frozen_string_literal: true

module Types
  module Enum
    class TnCVersionEnum < Types::Base::BaseEnum
      description 'Terms & Condition versions accepted'

      value '1.0', 'To be endorsed by a moderator',
            value: 'male'
    end
  end
end
