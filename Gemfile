# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 3.11'
gem 'rack', '~> 2.0.7'
gem 'rack-attack', '~> 6.0.0'
gem 'rack-cors', '~> 1.0.3', require: 'rack/cors'
gem 'rails', '~> 5.2.3'

group :development, :test do
  gem 'awesome_print', '~> 1.8.0', require: false
  gem 'brakeman', '~> 4.5.1', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'graphiql-rails', '~> 1.7.0'
  gem 'mailcatcher', '~> 0.2.4'
end

group :development do
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-bundler', '~> 1.6', require: false
  gem 'capistrano-nginx', '~> 1.0', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rails-console', '~> 2.3', require: false
  gem 'capistrano-rake', '~> 0.2.0', require: false
  gem 'capistrano-upload-config', '~> 0.8.2', require: false
  gem 'capistrano3-nginx', '~> 3.0', require: false
  gem 'capistrano3-puma', '~> 3.1', require: false
  gem 'listen', '>= 3.0.5', '< 3.2.0'
  gem 'rvm1-capistrano3', '~> 1.4', require: false
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'email_spec', '~> 2.2.0'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rantly', '~> 2.0.0'
  gem 'rspec', '~> 3.8.0'
  gem 'rspec-rails', '~> 3.8.2'
  gem 'shrine-memory', '~> 0.3.0'
  gem 'simplecov', '~> 0.16.1'
  gem 'vcr', '~> 4.0.0'
  gem 'webmock', '~> 3.5.1'
end

group :production do
  gem 'cloudflare-rails', '~> 0.4.0'
  gem 'postmark-rails', '~> 0.19.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '1.2019.1'

gem 'audited', '~> 4.8.0'
gem 'bcrypt_pbkdf', '< 2.0.0'
gem 'cancancan', '~> 3.0.1'
gem 'data_uri', '~> 0.1.0'
gem 'devise', '~> 4.6.2'
gem 'devise_token_auth', '~> 1.1.0'
gem 'digix-eth', '~> 0.5.6', require: 'eth'
gem 'discard', '~> 1.1.0'
gem 'dotenv-rails', '~> 2.7'
gem 'dry-logic', '~> 0.6.1'
gem 'dry-matcher', '~> 0.7.0'
gem 'dry-monads', '~> 1.2.0'
gem 'dry-struct', '~> 0.7.0'
gem 'dry-transaction', '~> 0.13.0'
gem 'dry-types', '~> 0.15.0'
gem 'dry-validation', '~> 0.13.0'
gem 'ed25519', '< 2.0.0'
gem 'factory_bot', '~> 5.0.2'
gem 'factory_bot_rails', '~> 5.0.1'
gem 'faker', '>= 1.9.1', require: false
gem 'faraday', '~> 0.15.4'
gem 'faraday_json', '~> 0.1.4'
gem 'fastimage', '~> 2.1.5'
gem 'graphql', '~> 1.9.3'
gem 'image_processing', '~> 1.9.0'
gem 'maxmind-db', '~> 1.0.0'
gem 'mime-types', '~> 3.2.2'
gem 'mini_magick', '~> 4.9.3'
gem 'mysql2', '~> 0.5.2'
gem 'rails_event_store', '~> 0.38.1'
gem 'roda', '~> 3.20.0'
gem 'rufus-scheduler', '~> 3.6'
gem 'shrine', '~> 2.16.0'

gem 'newrelic_rpm', '~> 6.5'
