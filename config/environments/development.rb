# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local = true

  config.cache_store = :file_store, Rails.root.join('tmp', 'cache')

  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'localhost', port: 23_000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('MAILER_HOST') { 'localhost' },
    port: ENV.fetch('MAILER_PORT') {  1025 }
  }

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  if (google_username = ENV.fetch('GOOGLE_USERNAME') { nil }) &&
     (google_password = ENV.fetch('GOOGLE_PASSWORD') { nil })

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: google_username,
      password: google_password,
      address: 'smtp.gmail.com',
      domain: 'hello.world.com',
      port: '587',
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end
