# frozen_string_literal: true

require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/plugins/download_endpoint'

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
  store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads')
}

Shrine.plugin :activerecord
Shrine.plugin :logging, logger: Rails.logger
Shrine.plugin :download_endpoint, prefix: 'attachments', download_options: {
  sse_customer_algorithm: 'AES256',
  sse_customer_key: 'electron-core',
  sse_customer_key_md5: '1b75deafc1a12173cfc19c7cf83e0229'
}
