# frozen_string_literal: true

require 'cancancan'

module Types
  module User
    class AppUserType < Types::Base::BaseObject
      description 'Application user data such as country.'

      field :country, Types::Value::CountryValue,
            null: true,
            description: <<~EOS
              The country the user is accessing from based on IP.
                If the country cannot be inferred or on the list, this is null.
            EOS
    end
  end
end
