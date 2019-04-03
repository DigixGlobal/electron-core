# frozen_string_literal: true

module AccountService
  class RegisterUser
    include SolidUseCase

    steps :validate_and_save, :send_confirmation

    def validate_and_save(params)
      user = User.new(params)

      return fail(:invalid_data, errors: user.errors) unless user.valid? && user.save

      continue(user: user)
    end

    def send_confirmation(user:)
      user.send_confirmation_instructions

      continue(user: user)
    end
  end

  class RequestAuthorization
    include SolidUseCase

    steps :find_by_credentials, :check_confirmed, :generate_token

    def find_by_credentials(email: nil, password: nil)
      unless (user = User.find_by(email: email)) && user.valid_password?(password)
        return fail(:invalid_credentials)
      end

      continue(user: user)
    end

    def check_confirmed(user:)
      return fail(:user_unconfirmed) unless user.confirmed?

      continue(user: user)
    end

    def generate_token(user:)
      continue(token: user.create_new_auth_token)
    end
  end

  class RequestPasswordReset
    include SolidUseCase

    steps :find_by_email, :send_password_reset

    def find_by_email(email:)
      unless (user = User.find_by(email: email)) && user.confirmed?
        return fail(:user_not_found)
      end

      continue(user: user)
    end

    def send_password_reset(user:)
      token = user.send_reset_password_instructions

      continue(user: user, token: token)
    end
  end

  class ConfirmUser
    include SolidUseCase

    steps :confirm_by_token, :create_kyc

    def confirm_by_token(token: '')
      user = User.confirm_by_token(token)

      unless user.errors[:confirmation_token].blank?
        return fail(:user_not_found, errors: user.errors)
      end

      return fail(:user_already_confirmed, errors: user.errors) unless user.errors[:email].blank?

      continue(user: user)
    end

    def create_kyc(user:)
      continue(user: user)
    end
  end

  class PasswordResetResult
    include ActiveModel::Validations

    attr_accessor :token, :password, :password_confirmation

    validates :token,
              presence: true
    validates :password,
              presence: true,
              confirmation: true

    validate :token_must_be_valid, :password_must_be_valid

    def token_must_be_valid
      unless token.blank? ||
             User.with_reset_password_token(token)
        errors.add(:token, 'is not valid or expired')
      end
    end

    def password_must_be_valid
      user = User.new(password: password)

      user.valid?

      errors.add(:password, user.errors[:password].first) unless user.errors[:password].empty?
    end

    def user_from_token
      User.with_reset_password_token(token)
    end
  end

  class ResetPassword
    include SolidUseCase

    steps :validate_and_update

    def validate_and_update(token: '', password: '', password_confirmation: '')
      result = PasswordResetResult.new
      result.token = token
      result.password = password
      result.password_confirmation = password_confirmation

      return fail(:invalid_data, errors: result.errors) unless result.valid?

      user = result.user_from_token
      user.reset_password(
        result.password,
        result.password_confirmation
      )

      continue(user: user)
    end
  end

  def self.register_user(attrs)
    RegisterUser.run(attrs)
  end

  def self.confirm_user_by_token(token)
    ConfirmUser.run(token: token)
  end

  def self.request_authorization(attrs)
    RequestAuthorization.run(attrs)
  end

  def self.request_password_reset(email)
    RequestPasswordReset.run(email: email)
  end

  def self.reset_password(attrs)
    ResetPassword.run(attrs)
  end
end
