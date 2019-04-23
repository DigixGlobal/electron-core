# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    token = params[:confirmation_token]

    result = AccountService.confirm_user_by_token(token)

    AppMatcher.result_matcher.call(result) do |m|
      m.success do |resource|
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for('', resource) }
      end

      m.failure(:user_not_found) do |_|
        errors = { confirmation_token: ['is invalid'] }

        respond_with_navigational(errors, status: :unprocessable_entity) { render :new }
      end

      m.failure(:user_already_confirmed) do |_|
        errors = { email: ['was already confirmed, please try signing in'] }

        respond_with_navigational(errors, status: :unprocessable_entity) { render :new }
      end
    end
  end

  protected

  def after_confirmation_path_for(_resource_name, _resource)
    'https://community.digix.global'
  end
end
