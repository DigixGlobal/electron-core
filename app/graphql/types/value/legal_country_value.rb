# frozen_string_literal: true

module Types
  module Value
    class LegalCountryValue < Types::Base::BaseScalar
      description <<~EOS
        This is just `CountryValue` but must be from a legal country.
         You can check blocked countries from `countries` query.
      EOS

      def self.coerce_input(input, _context)
        if Rails.configuration.countries
                .find_index do |country|
                  country['value'] == input && country['blocked'] == false
                end
                .nil?
          raise GraphQL::CoercionError, "#{input.inspect} is not a valid or is a blocked country"
        else
          input
        end
      end

      def self.coerce_result(value, _context)
        value
      end
    end
  end
end
