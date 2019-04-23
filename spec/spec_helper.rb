# frozen_string_literal: true

require 'solid_use_case'
require 'solid_use_case/rspec_matchers'

require 'email_spec'
require 'email_spec/rspec'

ENV['RANTLY_VERBOSE'] ||= '0'
ENV['RANTLY_COUNT'] ||= '10'

require 'rantly'
require 'rantly/shrinks'
require 'rantly/rspec_extensions'

require 'webmock/rspec'

require 'cancan/matchers'

require 'shrine/storage/memory'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.include(SolidUseCase::RSpecMatchers)

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = :should
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.fail_fast = true
  config.formatter = 'documentation'
  config.color = true
  config.order = :defined
  config.profile_examples = 10
end
