# frozen_string_literal: true

require 'ipaddr'

module Resolvers
  class AppUserResolver < Types::Base::BaseResolver
    type Types::User::AppUserType, null: false

    def resolve
      ip_address = context[:ip_address]

      {
        country: country_from_ip(ip_address)
      }
    end

    def country_from_ip(ip_address)
      return nil unless (data = Rails.configuration.country_ips.get(ip_address))

      code = data.dig('country', 'iso_code') ||
             data.dig('continent', 'code') ||
             ''

      return nil unless Rails.configuration.countries
                             .map { |country| country['value'] }
                             .member?(code)

      code
    rescue IPAddr::AddressFamilyError, IPAddr::InvalidAddressError
      nil
    end
  end
end
