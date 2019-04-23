# frozen_string_literal: true

module SupportTypes
  class Entity < Dry::Struct
    transform_keys(&:to_sym)

    attribute(:id, Types::String)
  end

  class Struct < Dry::Struct
    transform_keys(&:to_sym)
  end
end
