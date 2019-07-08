# frozen_string_literal: true

# From https://github.com/rmosolgo/graphiql-rails/issues/36#issuecomment-341765388
module GraphiQLRailsEditorsControllerDecorator
  def self.prepended(base)
    base.prepend_before_action :set_auth_headers, only: :show
  end

  protected

  def set_auth_headers
    current_user =
      if (user_id = params.fetch(:user_id, nil))
        User.find_by(id: user_id)
      elsif (email = params.fetch(:email, nil))
        User.find_by(email: email)
      end

    if current_user
      Rails.logger.info "Using #{current_user.email} as `current_user`"

      user_auth_token = current_user.create_new_auth_token

      GraphiQL::Rails.config.headers['accessToken'] = ->(context) { user_auth_token['accessToken'] }
      GraphiQL::Rails.config.headers['client'] = ->(context) { user_auth_token['client'] }
      GraphiQL::Rails.config.headers['uid'] = ->(context) { user_auth_token['uid'] }

      GraphiQL::Rails.config.logo = "Current User: #{current_user.email}"
      GraphiQL::Rails.config.title = 'Electron API GraphiQL'
    else
      GraphiQL::Rails.config.headers['accessToken'] = ->(context) { '' }
      GraphiQL::Rails.config.headers['client'] = ->(context) { '' }
      GraphiQL::Rails.config.headers['uid'] = ->(context) { '' }

      GraphiQL::Rails.config.logo = 'No Current User. Add the query param `user_id` or `email` and restart if you need it.'
      GraphiQL::Rails.config.title = 'Electron API GraphiQL (UNAUTHORIZED)'
    end

    GraphiQL::Rails.config.headers['X-Forwarded-For'] = ->(context) { params.fetch(:ip_address, '127.0.0.1') }
  end
end

GraphiQL::Rails::EditorsController.send :prepend, GraphiQLRailsEditorsControllerDecorator
