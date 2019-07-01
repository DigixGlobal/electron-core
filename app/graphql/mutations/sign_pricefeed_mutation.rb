# frozen_string_literal: true

module Mutations
  class SignPricefeedMutation < Types::Base::BaseMutation
    description <<~EOS
      Given a current user, a pair and an amount, request to sign a pricefeed.
    EOS

    argument :pair, Types::Enum::PricefeedPairEnum,
             required: true,
             description: 'Pricefeed pair requested'
    argument :amount, Types::Scalar::PositiveFloat,
             required: true,
             description: 'Amount requested'

    field :signed_pricefeed, Types::Pricefeed::SignedPricefeedType,
          null: true,
          description: 'Signed pricefeed'
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - User has not ser Eth address yet
            - Tier for amount and pair not found
          EOS

    KEY = :signed_pricefeed

    def resolve(pair:, amount:)
      user = context[:current_user]

      result = PriceService.sign_pricefeed(
        user_id: user.id,
        amount: amount,
        pair: pair
      )

      AppMatcher.result_matcher.call(result) do |m|
        m.success do |value|
          model_result(KEY, value)
        end

        m.failure(:invalid_user) do
          form_error(KEY, 'User has not set Eth address yet')
        end

        m.failure(:invalid_data) do |errors|
          model_errors(KEY, errors)
        end

        m.failure(:tier_not_found) do
          form_error(KEY, 'Tier for amount and pair not found')
        end

        m.failure do |error|
          Rails.logger.error("Something went wrong: #{error}")
          form_error(KEY, 'Something went wrong. Please try again later.')
        end
      end
    end

    def self.authorized?(object, context)
      super && context.fetch(:current_user, nil)
    end
  end
end
