# frozen_string_literal: true

module Types
  module Enum
    class TncLanguageEnum < Types::Base::BaseEnum
      description 'Terms & Condition languages'

      value 'EN', 'English for a terms and condition',
            value: 'EN'
      value 'CH', 'Chinese for a terms and condition',
            value: 'CH'
    end
  end
end
