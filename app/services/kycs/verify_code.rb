# frozen_string_literal: true

require 'dry/monads/do'

module Kycs
  class VerifyCode
    include Dry::Transaction
    include Dry::Monads::Do

    M = Dry::Monads

    step :validate
    step :verify

    private

    MAX_BLOCK_DELAY = Rails.configuration.ethereum['max_block_delay'].to_i
    VERIFICATION_PATTERN = /\A(\d+)-(\h{2})-(\h{2})\Z/i.freeze

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:code)
          .filled(format?: VERIFICATION_PATTERN)
      end
    end

    def validate(code)
      result = schema.call(code: code)

      return M.Failure(type: :invalid_format) unless result.success?

      result.to_monad.fmap { |attrs| attrs[:code] }
    end

    def verify(code)
      block_number, first_two, last_two =
        code.match(VERIFICATION_PATTERN).captures

      block_number = block_number.to_i
      block_hash = "0x#{block_number.to_s(16)}"

      this_block_number = yield(BlockchainApi
                          .fetch_latest_block.or(M.Failure(type: :block_not_found))
                          .fmap { |latest_block| latest_block.fetch('number', '').to_i(16) })

      unless (this_block_number - block_number) <= MAX_BLOCK_DELAY
        return M.Failure(type: :verification_expired)
      end

      this_hash = yield(BlockchainApi
                  .fetch_block_by_block_number(block_hash).or(M.Failure(type: :block_not_found))
                  .fmap { |this_block| this_block.fetch('hash', '').slice(2..-1) })

      unless this_hash.slice(0, 2) == first_two &&
             this_hash.slice(-2, 2) == last_two
        return M.Failure(type: :invalid_hash)
      end

      M.Success()
    end
  end
end
