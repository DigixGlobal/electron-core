# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def change_eth_address_confirmation
    @user = params[:user]
    @token = params[:token]

    mail(to: @user.email, subject: 'Change eth address confirmation')
  end
end
