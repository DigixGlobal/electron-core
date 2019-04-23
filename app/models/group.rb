# frozen_string_literal: true

class Group < ApplicationRecord
  enum group: { kyc_officer: 'KYC_OFFICER', forum_admin: 'FORUM_ADMIN' }

  before_create :generate_uuid

  has_and_belongs_to_many :users
end
