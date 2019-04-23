# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'rails-controller-testing'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'Rakefile'
  add_filter '.rake'
  add_filter '/app/channels/'
  add_filter '/app/controllers/'
  add_filter '/app/graphql/electron_core_schema.rb'
  add_filter '/app/graphql/types'
  add_filter '/app/graphql/subscriptions'
  add_filter '/app/jobs/'
  add_filter '/app/mailers/'
  add_filter '/app/models/'
  add_filter '/app/services/predicates.rb'
  add_filter '/app/services/app_container.rb'
  add_filter '/app/services/app_matcher.rb'
  add_filter '/app/services/app_schema.rb'
  add_filter '/app/types/param_types.rb'
  add_filter '/bin/'
end
puts 'required simplecov'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  FactoryBot.register_strategy(:params_for, ParamsForStrategy)

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include SchemaHelpers, type: :schema

  %i[controller view request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end

  config.include ActiveSupport::Testing::TimeHelpers
end
