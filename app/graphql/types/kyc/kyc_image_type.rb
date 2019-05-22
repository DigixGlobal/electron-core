# frozen_string_literal: true

module Types
  module Kyc
    class KycImageType < Types::Base::BaseObject
      description 'Image/proof used for KYC such as jpegs, pngs or pdfs'

      field :original, Types::Value::ImageType,
            null: false,
            description: 'Original image'
      field :thumbnail, Types::Value::ImageType,
            null: false,
            description: 'Thumbnail of the image'
    end
  end
end
