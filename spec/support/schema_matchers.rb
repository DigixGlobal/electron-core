# frozen_string_literal: true

RSpec::Matchers.define :have_graphql_errors do
  match do |actual|
    !actual.dig('errors').blank?
  end
end

RSpec::Matchers.define :have_graphql_mutation_errors do |field|
  match do |actual|
    data = actual.fetch('data', {})

    if (field_data = data.fetch(field, nil))
      !field_data.fetch('errors', {}).blank?
    else
      true
    end
  end
end

RSpec::Matchers.define :has_graphql_form_error do |field, message|
  match do |actual|
    data = actual.fetch('data', {})

    if (field_data = data.fetch(field, nil))
      errors = field_data.fetch('errors', {})

      if !errors.blank?
        form_error = errors.first

        form_error.fetch('message', nil) == message
      else
        true
      end
    else
      true
    end
  end
end

RSpec::Matchers.define_negated_matcher :have_no_graphql_errors, :have_graphql_errors
RSpec::Matchers.define_negated_matcher :have_no_graphql_mutation_errors, :have_graphql_mutation_errors
