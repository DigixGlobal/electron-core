# frozen_string_literal: true

module Types
  module Scalar
    class PositiveInteger < Types::Base::BaseScalar
      description <<~EOS
        A integer that must be positive. Used for step values.
      EOS

      def self.coerce_input(input, _context)
        unless (value = Integer(input)) && value > 0
          raise ArgumentError
        end

        value
      rescue ArgumentError
        raise GraphQL::CoercionError,
              "#{input.inspect} is not a valid non-negative integer."
      end

      def self.coerce_result(value, _context)
        value
      end
    end
  end
end
