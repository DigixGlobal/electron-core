# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'rvm1/capistrano3'
require 'capistrano/bundler'

require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/rails/console'

require 'capistrano/puma'
install_plugin Capistrano::Puma

require 'capistrano/upload-config'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
