# frozen_string_literal: true

class AppSchema < Dry::Validation::Schema
  configure do
    def self.messages
      super.merge(en: { errors: {
                    email?: 'is not valid',
                    country?: 'is not a valid country',
                    legal_country?: 'is not a valid legal country',
                    rejection_reason?: 'is not a rejection reason',
                    eth_address?: 'is not a valid checksum address',
                    future_date?: 'is not a future date'
                  } })
    end
  end

  def future_date?(value)
    value > Date.current
  end

  def email?(value)
    !Devise.email_regexp.match(value).nil?
  end

  def country?(value)
    !Rails.configuration.countries
          .find_index { |country| country['value'] == value }
          .nil?
  end

  def legal_country?(value)
    !Rails.configuration.countries
          .filter { |country| !country['blocked'] }
          .find_index { |country| country['value'] == value }
          .nil?
  end

  def rejection_reason?(value)
    !Rails.configuration.rejection_reasons
          .find_index { |reason| reason['value'] == value }
          .nil?
  end

  def eth_address?(value)
    Eth::Utils.valid_address?(value)
  end

  def self.preprocess_spaces(attrs)
    attrs
      .map do |key, value|
      new_value = if value.is_a?(String)
                    value.strip.chomp
                  else
                    value
                  end

      [key, new_value]
    end
      .to_h
  end
end
