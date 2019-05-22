# frozen_string_literal: true

require 'cancancan'

class Kyc < ApplicationRecord
  MINIMUM_AGE = 18
  IMAGE_SIZE_LIMIT = 10.megabytes
  IMAGE_FILE_TYPES = ['image/jpeg', 'image/jpeg', 'image/png', 'application_pdf'].freeze

  before_create :generate_uuid

  include PictureUploader::Attachment.new(:residence_proof_image)
  include PictureUploader::Attachment.new(:identification_proof_image)
  include PictureUploader::Attachment.new(:identification_pose_image)

  enum applying_status: { drafted: 0, pending: 1, approving: 2, approved: 3, rejected: 4 }
  enum tier: { tier_1: 1, tier_2: 2 }
  enum identification_proof_type: {
    passport: 0,
    national_id: 1,
    identity_card: 2
  }, _prefix: :identification
  enum residence_proof_type: {
    utility_bill: 0,
    bank_statement: 1
  }, _prefix: :residence

  belongs_to :user,
             foreign_type: :string
  belongs_to :officer,
             class_name: 'User',
             foreign_key: :officer_id,
             foreign_type: :string,
             optional: true

  include Discard::Model
end
