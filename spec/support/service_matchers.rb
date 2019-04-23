# frozen_string_literal: true

RSpec::Matchers.define :has_failure_type do |failure_type|
  match do |actual|
    actual.failure? &&
      actual.or { |value| value.fetch(:type, nil) == failure_type }
  end
end

RSpec::Matchers.define :has_failure_error_field do |field_key|
  match do |actual|
    actual.failure? &&
      actual.or { |value| !value.dig(:errors, field_key).blank? }
  end
end

RSpec::Matchers.define :has_invalid_data_error_field do |field_key|
  match do |actual|
    actual.failure? &&
      actual.or do |value|
        value.fetch(:type, nil) == :invalid_data &&
          !value.dig(:errors, field_key).blank?
      end
  end
end
