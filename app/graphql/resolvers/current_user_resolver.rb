# frozen_string_literal: true

module Resolvers
  class CurrentUserResolver < Types::Base::BaseResolver
    type Types::User::UserType,
         null: true

    def resolve
      context[:current_user]
    end

    def self.authorized?(object, context)
      super && context.fetch(:current_user, nil)
    end
  end
end
