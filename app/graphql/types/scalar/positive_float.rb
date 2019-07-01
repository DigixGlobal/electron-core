# frozen_string_literal: true

module Types
  module Scalar
    class PositiveFloat < Types::Base::BaseScalar
      description <<~EOS
        A float that must be non-negative. Used for currencies or prices.
      EOS

      def self.coerce_input(input, _context)
        unless (value = Float(input)) && value >= 0
          raise ArgumentError
        end

        value
      rescue ArgumentError
        raise GraphQL::CoercionError,
              "#{input.inspect} is not a valid non-negative float number."
      end

      def self.coerce_result(value, _context)
        value
      end
    end
  end
end
