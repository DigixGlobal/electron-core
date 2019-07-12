# frozen_string_literal: true

DeviseTokenAuth.setup do |config|
  config.change_headers_on_each_request = false
  config.enable_standard_devise_support = true
  config.headers_names = { 'access-token': 'accessToken',
                           client: 'client',
                           expiry: 'expiry',
                           uid: 'uid',
                           'token-type': 'tokenType' }
  config.remove_tokens_after_password_reset = true
end

Devise.setup do |config|
  config.secret_key = ENV.fetch('DEVISE_SECRET_KEY') { '3335f02e6fecec7958748b3dd1692208bfc2e4efc125db135ee86558e18cf4fa015f1181c52db2ae3037ad638891f4232134d19b82dd957061ace0c02f0f146b' }
end
