# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             only: %i[confirmation password],
             path: '/accounts',
             controllers: {
               confirmations: 'users/confirmations',
               passwords: 'users/passwords'
             },
             path_names: {
               confirmations: 'verification',
               passwords: 'password'
             }

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/api' if Rails.env.development?
  mount Shrine::DownloadEndpoint => '/attachments'

  post '/api', to: 'graphql#execute'

  namespace :api, defaults: { format: :json } do
    mount_devise_token_auth_for 'User', at: 'authorization'
  end
end
