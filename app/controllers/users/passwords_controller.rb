# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  PORTAL_URI = ENV.fetch('PORTAL_URI') { 'http://localhost:5000' }

  def edit
    token = super

    error = if (user = User.with_reset_password_token(token))
              'token_expired' unless user.reset_password_period_valid?
            else
              'user_not_found'
            end

    redirect_to "#{PORTAL_URI}?reset_password_token=#{token}&error=#{error || ''}"
  end

  protected

  # HACK: Allow blank reset_password_token which handles flash
  def assert_reset_token_passed
    nil
  end

  def after_resetting_password_path_for(resource)
    super(resource)
  end

  def after_sending_reset_password_instructions_path_for(_resource_name)
    PORTAL_URI
  end
end
