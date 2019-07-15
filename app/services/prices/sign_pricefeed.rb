# frozen_string_literal: true

module Prices
  class SignPricefeed
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    PRICEFEED_PAIRS = %w[
      xau-usd eth-usd xbt-usd dai-usd xau-eth xau-dai xau-xbt
    ].freeze
    PRICEFEED_SECRET_MNEMONIC = ENV.fetch('SECRET_MNEMONIC') { 'cry segment blue hello bid rain sheriff educate couple random office heavy credit borrow sugar shrimp cousin creek boil heavy edit credit shaft arrow couple right boat idea fashion rack screen equip grace crack army gather green radar occur change debris canvas flip silent chaos rack talk holiday give climb success give drip cost lumber almost cry situate assist second credit box sheriff proud cube book sudden gather globe october thunder erosion cry reason off skull casino radar office chase coral loan mirror security chaos broken sugar charge cushion canyon assist general crime grape three cry' }
    PRICEFEED_DELIMITER = 0x3a.chr

    step :find_by_user_id
    step :validate
    step :fetch_vault
    step :fetch_pricefeed
    step :find_price_and_signer
    step :fetch_block_number
    step :sign

    private

    def schema
      Dry::Validation.Schema(AppSchema) do
        required(:amount) { (float? | int?) & gteq?(0.0) }
        required(:pair).value(included_in?: PRICEFEED_PAIRS)
      end
    end

    def find_by_user_id(user_id:, **attrs)
      unless (user = AccountService.find(user_id))
        return M.Failure(type: :user_not_found)
      end

      return M.Failure(type: :invalid_user) unless user.eth_address

      M.Success(**attrs, user: user)
    end

    def validate(amount:, pair:, **attrs)
      result = schema.call(amount: amount, pair: pair)

      unless result.success?
        return M.Failure(type: :invalid_data, errors: result.errors(full: false))
      end

      result.to_monad
            .fmap do |params|
        attrs.merge(
          amount: params[:amount],
          pair: params[:pair]
        )
      end
    end

    def fetch_vault(**attrs)
      M.Success(
        **attrs,
        vault: Eth::Vault.new(secret_seed_phrase: PRICEFEED_SECRET_MNEMONIC)
      )
    rescue StandardError
      M.Failure(type: :vault_not_found)
    end

    def fetch_pricefeed(**attrs)
      PriceService.fetch_pricefeed.fmap { |pricefeeds| attrs.merge(pricefeeds: pricefeeds) }
    end

    def find_price_and_signer(amount:, pair:, pricefeeds:, vault:, **attrs)
      matching_pricefeed = pricefeeds.find { |pricefeed| pricefeed.fetch(:pair, '') == pair }

      return M.Failure(type: :tier_not_found) unless matching_pricefeed

      matching_tier = matching_pricefeed
                      .fetch(:tiers, [])
                      .sort_by { |tier| tier.fetch(:minimum) }
                      .reverse
                      .select { |tier| amount >= tier.fetch(:minimum) }
                      .first

      return M.Failure(type: :tier_not_found) unless matching_tier

      M.Success(
        **attrs,
        price: matching_tier.fetch(:price),
        signing_key: vault.get_key(matching_tier.fetch(:index))
      )
    end

    def fetch_block_number(**attrs)
      BlockchainApi.fetch_latest_block_number
                   .fmap { |block_number| attrs.merge(block_number: block_number) }
    end

    def sign(user:, block_number:, signing_key:, price:)
      message = [
        '',
        user.eth_address[2..-1],
        block_number,
        price
      ].join(PRICEFEED_DELIMITER)

      rpc_signer = ::Eth::RpcSigner.new(signing_key)
      signature = rpc_signer.sign_message(message)

      M.Success(
        payload: message,
        signature: signature.rpc_signature.to_hex,
        price: price,
        signer: signature.signer
      )
    end
  end
end
