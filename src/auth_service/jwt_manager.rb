require 'jwt'

class InvalidTokenError < StandardError; end
class ExpiredTokenError < StandardError; end

class JwtManager
  JWT_SECRET = ENV.fetch('JWT_SECRET', 'sljf23iousaljdasklfjsa2349asfdas')
  def initialize; end

  def generate_jwt(payload, exp_in_seconds)
    payload[:exp] = Time.now.to_i + exp_in_seconds
    JWT.encode(payload, JWT_SECRET, 'HS256')
  end

  def decode_jwt(token)
    begin
      return nil if token.nil? || token.empty?
      JWT.decode(token, JWT_SECRET, true, {algorithm: 'HS256'}).first
    rescue JWT::ExpiredSignature
      raise ExpiredTokenError
    rescue JWT::DecodeError
      raise InvalidTokenError
    end
  end
end


