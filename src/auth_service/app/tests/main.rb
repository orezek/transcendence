# frozen_string_literal: true

require 'vault'

PASS_TOKEN = 'hvs.CAESIO9ULYvkvpKFnFkGd8qHY0qrYglEWQl8GS2Cnbl1gVRVGh4KHGh2cy44dVlnOXUwMHViTGlxYUlhSHZhbG1YRFI'
ROOT_TOKEN = 'hvs.j5txn8mxHRmiFYT2XDI9wFHM'

# Test vault api
Vault.configure do |config|
  config.address = ENV['VAULT_ADDR'] || 'http://127.0.0.1:8200' || 'http://secrets_service:8200'
  config.token = ENV['VAULT_TOKEN'] || PASS_TOKEN
end

secret = Vault.kv('password_manager').read('jwt_secret_key') #returns Vault object
puts secret.inspect
puts secret.data[:jwt_secret_key]


secret = Vault.kv('password_manager').read('jwt_secret_key').data[:jwt_secret_key]
puts secret