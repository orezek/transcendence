require 'sinatra'
require 'json'
require 'pg'
require 'sequel'
require 'bcrypt'
require './utils/jwt_manager'
require './db_config/db_setup'

class AuthService < Sinatra::Base
  ACCESS_TOKEN_VALIDITY = 60 # 1 minute
  REFRESH_TOKEN_VALIDITY = 60 * 60 * 24 * 7 # 7 days
  set :bind, '0.0.0.0'
  set :port, 4567
  def initialize
    super
    @jwt_manager = JwtManager.new
  end
  db = DBSetup.new(ENV['RACK_ENV'] || 'development')
  DB = db.db

  # Middleware to parse JSON body = before any route processing do this below
  before do
    if request.content_type&.include?('application/json')
      begin
        request.body.rewind
        body_content = request.body.read.strip
        halt 400, { error: 'Empty request body' }.to_json if body_content.empty?

        @request_payload = JSON.parse(body_content, symbolize_names: true)
      rescue JSON::ParserError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end
    end
  end

  def authenticate_request!
    # Extract token from headers
    token = extract_token_from_headers
    halt 401, { error: 'Missing or invalid token' }.to_json if token.nil? || token.empty?

    # Decode the token
    begin
      decoded_token = @jwt_manager.decode_jwt(token)
    rescue InvalidTokenError => e
      halt 401, { error: e.message }.to_json
    rescue ExpiredTokenError => e
      halt 401, { error: e.message }.to_json
    end

    # Look up user
    @current_user = User.where(id: decoded_token['user_id']).where(active: true).first
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user

    # Look up session
    ip_address = request.ip || 'unknown ip address'
    user_agent = request.user_agent || 'unknown user agent'
    @current_session = Session.where(
      user_id: @current_user.id,
      ip_address: ip_address,
      user_agent: user_agent,
      revoked: false
    ).first

    # Check session exists
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
  end


  private

  def extract_token_from_headers
    auth_header = request.env['HTTP_AUTHORIZATION']
    auth_header&.split(' ')&.last
  end


  # Register API route
  post '/api/user' do
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
    # Extract and validate input from @request_payload
    username = @request_payload[:username]
    password = @request_payload[:password]
    ip_address = request.ip || 'unknown ip address'
    user_agent = request.user_agent || 'unknown user agent'
    halt 400, { error: 'Username and password are required' }.to_json unless username && password

    # Fetch the user from the database
    user = User.where(username: username).where(active: true).first
    halt 401, { error: 'Invalid username or password' }.to_json unless user

    # Validate password
    unless BCrypt::Password.new(user.password_hash) == password
      halt 401, { error: 'Invalid username or password' }.to_json
    end
    # Check if a session already exists
    existing_session = Session.where(
      user_id: user.id,
      ip_address: ip_address,
      user_agent: user_agent,
      revoked: false
    ).first
    refresh_token = @jwt_manager.generate_jwt({
                                                user_id: user.id,
                                                username: user.username
                                              },
                                              REFRESH_TOKEN_VALIDITY)
    if existing_session
      # Renew the refresh token and update the session
      existing_session.update(refresh_token: refresh_token, expires_at: Time.now + REFRESH_TOKEN_VALIDITY)
    else
      # Generate a new session
      session = Session.new(
        user_id: user.id,
        refresh_token: refresh_token,
        ip_address: ip_address,
        user_agent: user_agent,
        expires_at: Time.now + REFRESH_TOKEN_VALIDITY
      )
      halt 500, { error: 'Failed to create session' }.to_json unless session.save
    end

    # Generate short-lived access token
    token = @jwt_manager.generate_jwt({
                                        user_id: user.id,
                                        username: user.username
                                      },
                                      ACCESS_TOKEN_VALIDITY)
    # Respond with success
    halt 200, { message: 'Login successful', token: token }.to_json
  rescue Sequel::DatabaseError
    halt 500, { error: 'Database error occurred' }.to_json
  rescue StandardError => e
    halt 500, { error: 'An unexpected error occurred', details: e.message }.to_json
  end


  before '/api/user/logout' do
    authenticate_request!
  end
  post '/api/user/logout' do
    # Ensure the user is authenticated
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    @current_session.update(revoked: true)
    # Respond with success
    halt 200, { message: 'Logout successful' }.to_json
  end

  before '/api/user/info' do
    authenticate_request!
  end
  get '/api/user/info' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    user = @current_user
    status 200
    {
      message: 'User Data',
      user_id: user.id,
      username: user.username,
      avatar: user.avatar
    }.to_json
  end

  before '/api/token/refresh' do
    authenticate_request!
  end
  post '/api/token/refresh' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    # Renew the access token and return new token to user
    token = @jwt_manager.generate_jwt({
                                        user_id: @current_user.id,
                                        username: @current_user.username
                                      },
                                      ACCESS_TOKEN_VALIDITY)
    halt 200, { message: 'Refresh successful', token: token }.to_json
  end

  before '/api/sessions/logout/all' do
    authenticate_request!
  end
  delete '/api/sessions/logout/all' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    # invalidate all user sessions
    Session.where(user_id: @current_user.id).update(revoked: true)
    halt 200, { message: 'All sessions invalidated' }.to_json
  end

  before '/api/sessions' do
    authenticate_request!
  end
  get '/api/sessions' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    # retrieve all user sessions
    user_sessions = Session.where(user_id: @current_user.id).where(revoked: false).all
    session_data = user_sessions.map(&:values)
    halt 200, { message: session_data }.to_json
  end

  before '/api/user' do
    authenticate_request! if request.request_method == 'DELETE'
  end
  delete '/api/user' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session
    # invalidate user and sessions related to the user
    @current_user.update(active: false)
    Session.where(user_id: @current_user.id).update(revoked: true)
    halt 200, { message: 'User deleted' }.to_json
  end

  before '/api/user' do
    authenticate_request! if request.request_method == 'PATCH'
  end
  patch '/api/user' do
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user
    halt 401, { error: 'Unauthorized' }.to_json unless @current_session

    # Fetch the current user
    user = @current_user

    # Update user information
    user_data = {
      username: @request_payload[:username],
      password_hash: BCrypt::Password.create(@request_payload[:password]),
      email: @request_payload[:email],
      avatar: @request_payload[:avatar] || '/images/default-avatar.png'
    }

    # Assign new values
    user.set(user_data)

    # Validate and save the record
    if user.valid?
      user.save
      halt 200, { message: 'User updated successfully' }.to_json
    else
      halt 400, { errors: user.errors.full_messages }.to_json
    end
  end

end
AuthService.run!

# TODO
# handle properly file download = save path to db and save the binary to a location
# where nginx can reach
