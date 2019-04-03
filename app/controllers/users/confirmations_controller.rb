# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    token = params[:confirmation_token]

    AccountService.confirm_user_by_token(token).match do
      success do |result|
        resource = result[:user]
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for('', resource) }
      end

      failure do |result|
        respond_with_navigational(result[:errors], status: :unprocessable_entity) { render :new }
      end
    end
  end

  protected

  def after_confirmation_path_for(_resource_name, _resource)
    'https://community.digix.global'
  end
end
