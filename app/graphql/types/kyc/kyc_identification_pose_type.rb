# frozen_string_literal: true

module Types
  module Kyc
    class KycIdentificationPoseType < Types::Base::BaseObject
      description 'ID pose for KYC'

      field :image, Types::Kyc::KycImageType,
            null: true,
            description: <<~EOS
              Image of the pose with the ID.
               It is possible for this to be `null` after submitting
               since file storage is asynchronous, so be careful with the mutation.
               However, it should be a valid object in practice.
            EOS
      end
  end
end
