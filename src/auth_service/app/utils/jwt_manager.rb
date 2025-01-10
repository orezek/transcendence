require 'jwt'
require 'vault'

class InvalidTokenError < StandardError; end
class ExpiredTokenError < StandardError; end

class JwtManager
  #JWT_SECRET = ENV.fetch('JWT_SECRET', 'sljf23iousaljdasklfjsa2349asfdas')
  # PASS_TOKEN = 'hvs.CAESIO9ULYvkvpKFnFkGd8qHY0qrYglEWQl8GS2Cnbl1gVRVGh4KHGh2cy44dVlnOXUwMHViTGlxYUlhSHZhbG1YRFI'
  PASS_TOKEN = File.read('/vault/shared_data/password_manager_token').strip
  def initialize
    Vault.configure do |config|
      config.address = ENV['VAULT_ADDR'] || 'http://secrets_service:8200'
      config.token = ENV['VAULT_TOKEN'] || PASS_TOKEN
    end
    @jwt_secret = Vault.kv('password_manager').read('jwt_secret_key').data[:jwt_secret_key]
    puts "jwt_secret_key: #{@jwt_secret}"
  end

  def generate_jwt(payload, exp_in_seconds)
    payload[:exp] = Time.now.to_i + exp_in_seconds
    JWT.encode(payload, @jwt_secret, 'HS256')
  end

  def decode_jwt(token)
    begin
      return nil if token.nil? || token.empty?
      puts "JWT Token - decode call: #{@jwt_secret}"
      JWT.decode(token, @jwt_secret, true, {algorithm: 'HS256'}).first
    rescue JWT::ExpiredSignature
      raise ExpiredTokenError
    rescue JWT::DecodeError
      raise InvalidTokenError
    end
  end
end


