# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  CONFIRMATION_URI = ENV.fetch('CONFIRMATION_URI') { 'https://localhost:5000/#/portal/register/confirmation' }

  def show
    token = params[:confirmation_token]

    result = AccountService.confirm_user_by_token(token)

    AppMatcher.result_matcher.call(result) do |m|
      m.success do |resource|
        redirect_to after_confirmation_path_for('', resource)
      end

      m.failure(:user_not_found) do |_|
        redirect_to after_confirmation_path_for('user_not_found', resource)
      end

      m.failure(:user_already_confirmed) do |_|
        redirect_to after_confirmation_path_for('user_already_confirmed', resource)
      end
    end
  end

  protected

  def after_confirmation_path_for(error, _resource)
    "#{CONFIRMATION_URI}?error=#{error || ''}"
  end
end
