# frozen_string_literal: true

module Types
  module Enum
    class PricefeedPairEnum < Types::Base::BaseEnum
      description 'Pricefeed pair/symbols'

      value 'XAU_USD', 'XAU to USD',
            value: 'xau-usd'
      value 'XAU_DAI', 'XAU to DAI',
            value: 'xau-dai'
      value 'XAU_XBT', 'XAU to XBT',
            value: 'xau-xbt'
      value 'XAU_ETH', 'XAU to ETH',
            value: 'xau-eth'
    end
  end
end
