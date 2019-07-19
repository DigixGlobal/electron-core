# frozen_string_literal: true

module AccountTypes
  class UserEntity < SupportTypes::Entity
    attribute(:email, Types::String)
    attribute(:tnc_version, Types::String)
    attribute(:eth_address, Types::String.optional)

    def self.from_model(model)
      new(
        id: model.id,
        email: model.email,
        tnc_version: model.tnc_version,
        eth_address: model.eth_address
      )
    end

    def to_model
      User.find(id)
    end
  end

  class EthAddressChangeEntity < SupportTypes::Entity
    attribute(:eth_address, Types::String)
    attribute(:sent_at, Types::Date)

    def self.from_model(model)
      new(
        id: model.id,
        eth_address: model.new_eth_address,
        sent_at: model.change_eth_address_sent_at
      )
    end
  end
end
