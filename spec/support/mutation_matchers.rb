# frozen_string_literal: true

RSpec::Matchers.define :have_mutation_errors do |_expected|
  match do |actual|
    !actual[:errors].empty?
  end
end

RSpec::Matchers.define :have_mutation_result do |expected|
  match do |actual|
  end
end

RSpec::Matchers.define_negated_matcher :have_no_mutation_errors, :have_mutation_errors
