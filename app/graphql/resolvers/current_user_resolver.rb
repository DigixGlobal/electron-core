# frozen_string_literal: true

module Resolvers
  class CurrentUserResolver < Types::Base::BaseResolver
    type Types::User::UserType,
         null: false

    def resolve
      if (user = context[:current_user])
        AccountTypes::UserEntity.from_model(user)
      end
    end

    def self.unauthorized_object(_error)
      raise GraphQL::ExecutionError, 'Unauthorized access'
    end

    def self.authorized?(object, context)
      super && context.fetch(:current_user, nil)
    end
  end
end
