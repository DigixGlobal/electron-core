# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def change_eth_address_confirmation
    @user = params[:user]
    mail(to: @user.email, subject: 'Change Eth Address Confirmation')
  end
end
