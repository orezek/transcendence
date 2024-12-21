require 'jwt'

class InvalidTokenError < StandardError; end
class ExpiredTokenError < StandardError; end

class JwtManager
  JWT_SECRET = ENV.fetch('JWT_SECRET', 'sljf23iousaljdasklfjsa2349asfdas')
  DEFAULT_EXPIRATION = 24 * 60 * 60
  def initialize; end

  def generate_jwt(payload)
    exp = 24 * 60 * 60
    payload[:exp] = Time.now.to_i + DEFAULT_EXPIRATION
    JWT.encode(payload, JWT_SECRET, 'HS256')
  end

  def decode_jwt(token)
  begin
    return nil if token.nil? || token.empty?
    payload = JWT.decode(token, JWT_SECRET, true, {algorithm: 'HS256'}).first
    payload
  rescue JWT::ExpiredSignature
    raise ExpiredTokenError
  rescue JWT::DecodeError
    raise InvalidTokenError
  end
end

