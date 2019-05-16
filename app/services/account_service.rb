# frozen_string_literal: true

module AccountService
  def self.find(id)
    return nil unless (user = User.find_by(id: id))

    AccountTypes::UserEntity.from_model(user)
  end

  def self.find_by_address(address)
    return nil unless (user = User.find_by(eth_address: address))

    AccountTypes::UserEntity.from_model(user)
  end

  def self.register_user(attrs)
    Accounts::RegisterUser.new.call(attrs)
  end

  def self.confirm_user_by_token(token)
    Accounts::ConfirmUser.new.call(token)
  end

  def self.request_authorization(attrs)
    Accounts::RequestAuthorization.new.call(attrs)
  end

  def self.request_password_reset(email)
    Accounts::RequestPasswordReset.new.call(email)
  end

  def self.reset_password(attrs)
    Accounts::ResetPassword.new.call(attrs)
  end

  def self.change_eth_address(id, new_address)
    Accounts::ChangeEthAddress.new.call(id: id, eth_address: new_address)
  end
end
