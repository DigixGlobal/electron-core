# frozen_string_literal: true

require 'cancancan'

module Accounts
  class ChangeEthAddress
    include Dry::Transaction(container: AppContainer)

    M = Dry::Monads

    around :transaction, with: 'transaction'

    step :find_by_token
    step :change
    step :broadcast
    map :as_entity

    private

    def find_by_token(token)
      unless token && (user = User.find_by(change_eth_address_token: token))
        return M.Failure(type: :token_not_found)
      end

      M.Success(user)
    end

    def change(model)
      old_eth_address = model.eth_address

      unless model.update_attributes(
        eth_address: model.new_eth_address,
        new_eth_address: nil,
        change_eth_address_token: nil,
        change_eth_address_sent_at: nil
      )
        return M.Failure(type: :invalid_data, errors: model.errors)
      end

      M.Success(user: model, eth_address: old_eth_address)
    end

    def broadcast(user:, eth_address:)
      if Rails.env.test? # TODO: Pending processor
        result = KycApi.change_eth_address(eth_address, user.eth_address)

        return result if result.failure?
      end

      M.Success(user)
    end

    def as_entity(user)
      AccountTypes::UserEntity.from_model(user)
    end
  end
end
