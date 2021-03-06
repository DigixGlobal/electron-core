# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module ElectronCore
  class Application < Rails::Application
    config.load_defaults 5.2

    config.api_only = true
    config.to_prepare do
      Rails.configuration.event_store = RailsEventStore::Client.new
    end

    config.middleware.use Rack::Attack

    config.countries = JSON.parse(File.read('config/countries.json'))
    config.country_ips = MaxMind::DB.new(
      ENV.fetch('IP_DB') { 'config/GeoLite2-Country.mmdb' },
      mode: MaxMind::DB::MODE_MEMORY
    )

    config.rejection_reasons =
      JSON.parse(File.read('config/rejection_reasons.json'))

    config.ethereum = config_for(:ethereums)
  end
end
