# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  def edit
    token = super

    error = if (user = User.with_reset_password_token(token))
              'token_expired' unless user.reset_password_period_valid?
            else
              'user_not_found'
            end

    redirect_to "https://community.digix.global?reset_password_token=#{token}&error=#{error || ''}"
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
    'https://community.digix.global'
  end
end
