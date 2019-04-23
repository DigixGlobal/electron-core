# frozen_string_literal: true

module Predicates
  include Dry::Logic::Predicates

  predicate(:email?) do |value|
    !Devise.email_regexp.match(value).nil?
  end

  predicate(:country?) do |value|
    !Devise.email_regexp.match(value).nil?
  end
end
