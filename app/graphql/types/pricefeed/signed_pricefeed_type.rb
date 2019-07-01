# frozen_string_literal: true

module Types
  module Pricefeed
    class SignedPricefeedType < Types::Base::BaseObject
      description <<~EOS
        A signed pricefeed to pass to a smart contract.
      EOS

      field :signature, String,
            null: false,
            description: 'Signed payload'
      field :payload, String,
            null: false,
            description: 'Message payload'
      field :price, Float,
            null: false,
            description: 'Price determined by amount and pair'
      field :signer, Types::Scalar::EthAddress,
            null: false,
            description: 'The Eth address of the signer'
    end
  end
end
