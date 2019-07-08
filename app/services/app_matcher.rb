# frozen_string_literal: true

module AppMatcher
  def self.result_matcher
    success_case = Dry::Matcher::Case.new(
      match: ->(result) { result.success? },
      resolve: ->(result) { result.value! }
    )

    failure_case = Dry::Matcher::Case.new(
      match: lambda { |result, *pattern|
        if result.failure?
          if pattern.any?
            target_type = pattern.first

            result.or do |value|
              this_pattern = value.is_a?(Hash) ? value.fetch(:type, nil) : value

              this_pattern == target_type
            end
          else
            true
          end
        end
      },
      resolve: lambda { |result|
                 result.or { |value| value.fetch(:errors, nil) || value.fetch(:type, nil) }
               }
    )

    Dry::Matcher.new(success: success_case, failure: failure_case)
  end
end
