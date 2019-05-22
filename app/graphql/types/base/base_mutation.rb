# frozen_string_literal: true

require 'dry-matcher'
require 'dry-monads'

module Types
  module Base
    class BaseMutation < GraphQL::Schema::RelayClassicMutation
      def self.visible?(context)
        authorized?(nil, context)
      end

      def self.accessible?(context)
        authorized?(nil, context)
      end

      def self.authorized?(_object, _context)
        true
      end

      class UserErrorType < Types::Base::BaseObject
        description 'An user-readable error'

        field :message, String,
              null: false,
              description: 'A description of the error'
        field :field, String,
              null: true,
              description: 'Which input final value this error came from'
      end

      protected

      def model_result(key, model)
        result = {}
        result[key] = model
        result[:errors] = []

        result
      end

      def model_errors(key, model_errors)
        result = {}
        result[key] = nil
        result[:errors] = model_errors.map do |inner_key, message|
          {
            field: inner_key.to_s.tr('.', '_').camelize(:lower),
            message: full_message(inner_key, message)
          }
        end

        result
      end

      # Copied and modified from https://apidock.com/rails/v4.2.7/ActiveModel/Errors/full_message
      def full_message(attribute, message)
        return message if attribute == :base

        attr_name = attribute.to_s.tr('.', '_').humanize
        I18n.t(:"errors.format",
               default: '%{attribute} %{message}',
               attribute: attr_name,
               message: message)
      end

      def form_error(key, error_message = 'Form Error', field = '_FORM')
        result = {}
        result[key] = nil
        result[:errors] = [
          {
            field: field,
            message: error_message
          }
        ]

        result
      end
    end
  end
end
