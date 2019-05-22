# frozen_string_literal: true

module Types
  module Value
    class RejectionReasonValue < Types::Base::BaseScalar
      description <<~EOS
        A rejection rason represented by a string that comes form `RejectionReason.value`
      EOS

      def self.coerce_input(input, _context)
        unless AppSchema.new.rejection_reason?(input)
          raise GraphQL::CoercionError, "#{input.inspect} is not a valid rejection reason"
        end

        input
      end

      def self.coerce_result(value, _context)
        value
      end
    end
  end
end
