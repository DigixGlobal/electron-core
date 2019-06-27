# frozen_string_literal: true

module Types
  module Value
    class ImageType < Types::Base::BaseObject
      description 'Image type'

      field :content_type, String,
            null: false,
            description: 'Content type of the image such as `application/png`'
      field :uri, String,
            null: false,
            description: 'URI for the image'
      field :data_url, String,
            null: false,
            description: 'Base64 encoded string for the data itself'

      def content_type
        object.metadata['mime_type']
      end

      def uri
        object.download_url
      end

      def data_url
        "data:#{object.metadata['mime_type']};base64,#{Base64.strict_encode64(object.read)}"
      end
    end
  end
end
