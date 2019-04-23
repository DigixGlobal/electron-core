# frozen_string_literal: true

module AccountTypes
  class UserEntity < SupportTypes::Entity
    attribute(:email, Types::String)
    attribute(:tnc_version, Types::String)

    def self.from_model(model)
      new(
        id: model.id,
        email: model.email,
        tnc_version: model.tnc_version
      )
    end
  end
end
