# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models

  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  before_create :generate_uuid

  validates :email,
            length: { maximum: 254 }
end
