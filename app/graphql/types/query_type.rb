# frozen_string_literal: true

module Types
  class QueryType < Types::Base::BaseObject
    field :current_user, Types::User::UserType,
          resolver: Resolvers::CurrentUserResolver,
          description: "Get the current user's information"
  end
end
