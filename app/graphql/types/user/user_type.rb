# frozen_string_literal: true

module Types
  module User
    class UserType < Types::Base::BaseObject
      description 'DAO users who publish proposals and vote for them'

      field :email, String,
            null: false,
            description: "User's email"

      def self.authorized?(object, context)
        super && context.fetch(:current_user, nil)
      end
    end
  end
end
