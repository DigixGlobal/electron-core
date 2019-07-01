# frozen_string_literal: true

module Types
  module Enum
    class PricefeedPairEnum < Types::Base::BaseEnum
      description 'Pricefeed pair/symbols'

      value 'XAU_USD', 'XAU to USD',
            value: 'xau-usd'
      value 'ETH_USD', 'ETH to USD',
            value: 'eth-usd'
      value 'XBT_USD', 'XBT to USD',
            value: 'xbt-usd'
      value 'DAI_USD', 'DAI to USD',
            value: 'dai-usd'
      value 'XAU_DAI', 'XAU to DAI',
            value: 'xau-usd'
      value 'XAU_XBT', 'XAU to XBT',
            value: 'xau-xbt'
      value 'XAU_ETH', 'XAU to ETH',
            value: 'xau-eth'
    end
  end
end
