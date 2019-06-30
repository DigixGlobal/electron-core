# frozen_string_literal: true

module Types
  module Tnc
    class TncType < Types::Base::BaseObject
      description 'The terms and condition (TnC) for the user.'

      field :version, String,
            null: false,
            description: 'The semantic version of the TnC'
      field :text, String,
            null: false,
            description: 'The long and legal text of the TnC'
    end
  end
end
