# frozen_string_literal: true

require 'rails_helper'

class TestImage < ApplicationRecord
  include PictureUploader::Attachment.new(:image)
end

RSpec.describe PictureUploader, type: :model do
  describe '.data_uri' do
    let(:data_url) { generate(:data_url).to_s }

    specify 'should work with valid url' do
      record = TestImage.new
      record.image_data_uri = data_url

      expect(record.valid?).to(be(true))
      expect(record.errors).to(be_empty)
    end

    def file_to_data_url(file_type, file_path)
      data = File.read(file_path)

      "data:#{file_type};base64,#{Base64.strict_encode64(data)}"
    end

    it 'should fail when file type is faked' do
      record = TestImage.new
      record.image_data_uri = file_to_data_url(
        'application/pdf',
        './spec/files/test.gif'
      )
      record.valid?

      expect(record.valid?).to(be(false))
      expect(record.errors[:image][0])
        .to(match(/isn't of allowed type/))
    end
  end

  describe PictureUploader::Attacher do
    let(:attacher) { described_class.new(TestImage.new, :image) }

    describe 'validations' do
      specify 'should work' do
        attacher.assign(File.open('./spec/files/slightly-below-limit.jpg'))

        expect(attacher.errors).to(be_empty)
      end

      it 'pdfs should work' do
        attacher.assign(File.open('./spec/files/test.pdf'))

        expect(attacher.errors).to(be_empty)
      end

      it 'should fail when too large' do
        attacher.assign(File.open('./spec/files/slightly-above-limit.jpg'))

        expect(attacher.errors).to_not(be_empty)
        expect(attacher.errors[0]).to(eq('is too large (max is 10 MB)'))

        attacher.assign(File.open('./spec/files/above-limit.jpg'))

        expect(attacher.errors).to_not(be_empty)
        expect(attacher.errors[0]).to(eq('is too large (max is 10 MB)'))
      end

      it 'should fail when file type is invalid' do
        attacher.assign(File.open('./spec/files/test.gif'))

        expect(attacher.errors).to_not(be_empty)
        expect(attacher.errors[0]).to(match(/allowed type/))
      end
    end
  end
end
