# frozen_string_literal: true

module Types
  module User
    class AuthorizationType < Types::Base::BaseObject
      description <<~EOS
        Authorization via Bearer Token.

        Set all the fields in this object as HTTP headers when making
          request to use this.
      EOS

      field :access_token, String,
            hash_key: 'accessToken',
            null: false,
            description: 'User and his/her session as hash'
      field :client, String,
            null: false,
            description: 'User and his/her device as hash'
      field :expiry, String,
            null: false,
            description: 'Authorization expiry in string seconds'
      field :token_type, String,
            hash_key: 'tokenType',
            null: false,
            description: 'Authorization token type which is `Bearer` in this case'
      field :uid, String,
            null: false,
            description: 'User unique authorization ID'
    end
  end
end
