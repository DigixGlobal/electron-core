# frozen_string_literal: true

require 'image_processing/mini_magick'

class PictureUploader < Shrine
  include ImageProcessing::MiniMagick

  MiniMagick = ImageProcessing::MiniMagick

  FILE_SIZE_LIMIT = 10.megabytes
  FILE_MIME_TYPES = [
    'image/jpg',
    'image/jpeg',
    'image/png',
    'application/pdf'
  ].freeze
  FILE_TYPES = %w[jpg jpeg png pdf].freeze

  plugin :data_uri
  plugin :infer_extension
  plugin :determine_mime_type
  plugin :remove_attachment
  plugin :store_dimensions
  plugin :validation_helpers
  plugin :pretty_location
  plugin :processing
  plugin :versions
  if Rails.env.test?
    plugin :keep_files
  else
    plugin :delete_promoted
    plugin :delete_raw
  end
  plugin :cached_attachment_data

  Attacher.validate do
    validate_max_size FILE_SIZE_LIMIT, message: 'is too large (max is 10 MB)'
    validate_mime_type_inclusion FILE_MIME_TYPES
    validate_extension_inclusion FILE_TYPES
  end

  process(:store) do |io|
    original = io.to_io

    {
      original: original,
      thumbnail: MiniMagick.source(original).resize_to_fit!(nil, 100)
    }
  end
end
