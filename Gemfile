# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.3'

group :development, :test do
  gem 'awesome_print', '~> 1.8.0', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker', '>= 1.9.1', require: false
  gem 'graphiql-rails', '~> 1.7.0'
  gem 'mailcatcher', '~> 0.2.4'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'email_spec', '~> 2.2.0'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rantly', '~> 2.0.0'
  gem 'rspec', '~> 3.8.0'
  gem 'rspec-rails', '~> 3.8.2'
  gem 'simplecov', '~> 0.16.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'devise', '~> 4.6.2'
gem 'devise_token_auth', '~> 1.1.0'
gem 'factory_bot', '~> 5.0.2'
gem 'factory_bot_rails', '~> 5.0.1'
gem 'graphql', '~> 1.9.3'
gem 'mysql2', '~> 0.5.2'
gem 'solid_use_case', '~> 2.2.0'
