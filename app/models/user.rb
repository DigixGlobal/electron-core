# frozen_string_literal: true

require 'cancancan'

class User < ApplicationRecord
  extend Devise::Models

  devise :confirmable, :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  before_create :generate_uuid

  has_one :kyc, -> { kept }
  has_and_belongs_to_many :groups

  audited only: :eth_address, update_with_comment_only: true, on: [:update]

  enum change_eth_address_status: { pending: 0, updated: 1, failed: 2 }
end
