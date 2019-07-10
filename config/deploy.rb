# frozen_string_literal: true

lock '~> 3.11.0'

set :application, 'electron_core'
set :repo_url, 'git@github.com:DigixGlobal/electron-core.git'
set :branch, 'develop'
set :rails_env, 'production'
set :stage, :staging

set :linked_dirs, fetch(:linked_dirs, []).push('storage', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :deploy_to, '/home/appuser/apps/electron_core'
set :pty, true
set :keep_releases, 5

set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_bind, 'tcp://127.0.0.1:23000'
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :rvm_type, :user
set :rvm_ruby_version, '2.6.2@electron_core'

set :rvm1_ruby_version, '2.6.2'
set :rvm_map_bins, %w[rake gem bundle ruby puma pumactl]

append :linked_dirs, '.bundle'
set :linked_files, %w[.env]
set :config_files, fetch(:linked_files)

namespace :deploy do
  # before 'deploy:check:linked_files', 'config:push'

  before 'deploy', 'rvm1:install:rvm'
  before 'deploy', 'rvm1:install:ruby'

  before 'check:linked_files', 'puma:config'
  after 'deploy', 'puma:restart'
end
