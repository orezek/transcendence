require 'sinatra'
require 'json'
require 'pg'
require 'sequel'
require 'bcrypt'
require './jwt_manager'
require './config/db_setup'

class AuthService < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 4567
  def initialize
    super
    @jwt_manager = JwtManager.new
  end

  db = DBSetup.new(ENV['RACK_ENV'] || 'development')
  DB = db.db

  def authenticate_request!
    auth_header = request.env['HTTP_AUTHORIZATION']
    token = auth_header&.split(' ')&.last
    if token.nil? || token.empty?
      halt 401, { error: 'Missing token'}.to_json
    end
    begin
      decoded_token = @jwt_manager.decode_jwt(token)
    rescue InvalidTokenError => e
      halt 401, { error: e.message }.to_json
    rescue ExpiredTokenError => e
      halt 401, { error: e.message }.to_json
    end
    @current_user = User.where(id: decoded_token['user_id']).first
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
  end

  # Middleware to parse JSON body = before any route processing do this below
  before do
    if request.content_type == 'application/json'
      begin
        request.body.rewind
        @request_payload = JSON.parse(request.body.read, symbolize_names: true)
      rescue JSON::ParserError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end
    end
  end
  # Register API route
  post '/api/register' do
    user_data = {
      username: @request_payload[:username],
      password_hash: BCrypt::Password.create(@request_payload[:password]),
      email: @request_payload[:email],
      avatar: @request_payload[:avatar] || '/images/default-avatar.png'
    }
    user = User.new(user_data)
    if user.valid?
      user.save
      halt 201, { message: 'User registered successfully' }.to_json
    else
      halt 400, { errors: user.errors.full_messages }.to_json
    end
  end


  post '/api/login' do
    begin
      content_type :json
      username = @request_payload[:username]
      password = @request_payload[:password]
      # Halt if username or password is missing
      halt 400, { error: 'Username and password are required' }.to_json unless username && password
      # Fetch the user from the database
      user = User.where(username: username).first
      # Validate the password
      if user && BCrypt::Password.new(user.password_hash) == password
        token = @jwt_manager.generate_jwt(user_id: user.id, username: user.username)
        halt 200, { message: 'Login successful', token: token }.to_json
      else
        halt 401, { error: 'Invalid username or password' }.to_json
      end
    rescue Sequel::DatabaseError
      halt 500, { error: 'Internal Database Error' }.to_json
    rescue StandardError
      halt 500, {error: 'Internal Server Error'}.to_json
    end
  end

  before '/api/user' do
    authenticate_request!
  end
  get '/api/user' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    user = @current_user
    status 200
    {
      message: 'User Data',
      user_id: user.id,
      username: user.username,
      avatar: user.avatar
    }.to_json
  end
end
AuthService.run!
