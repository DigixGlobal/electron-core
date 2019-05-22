# frozen_string_literal: true

module Types
  module Scalar
    class EthAddress < Types::Base::BaseScalar
      description <<~EOS
        An eth address represented by a `String`.
      EOS

      def self.coerce_input(input, _context)
        unless AppSchema.new.eth_address?(input)
          raise GraphQL::CoercionError, "#{input.inspect} is not a valid checksum address"
        end

        input
      end

      def self.coerce_result(value, _context)
        value
      end
    end
  end
end
