# frozen_string_literal: true

class ElectronCoreSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  def self.unauthorized_object(error)
    raise GraphQL::ExecutionError,
          "An object of type #{error.type.graphql_name} was hidden due to permissions"
  end
end
