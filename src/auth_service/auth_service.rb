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
    puts "[DEBUG] Token: #{token}"
    halt 401, { error: 'Missing or invalid token' }.to_json if token.nil? || token.empty?

    # Decode the token
    begin
      decoded_token = @jwt_manager.decode_jwt(token)
      puts "[DEBUG] Token exp value: #{decoded_token['exp']}"
      puts "[DEBUG] Current time: #{Time.now.to_i}"
    rescue InvalidTokenError => e
      halt 401, { error: e.message }.to_json
    rescue ExpiredTokenError => e
      halt 401, { error: e.message }.to_json
    end

    # Look up user
    @current_user = User.where(id: decoded_token['user_id']).first
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user

    # Look up session
    ip_address = request.ip
    user_agent = request.user_agent
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
    # Extract and validate input from @request_payload
    username = @request_payload[:username]
    password = @request_payload[:password]
    ip_address = @request_payload[:ip_address] || request.ip
    user_agent = @request_payload[:user_agent] || request.user_agent

    halt 400, { error: 'Username and password are required' }.to_json unless username && password

    # Fetch the user from the database
    user = User.where(username: username).first
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

    if existing_session
      # Renew the refresh token and update the session
      refresh_token = @jwt_manager.generate_jwt(
        user_id: user.id,
        username: user.username,
        exp_in_seconds: 7 * 24 * 60 * 60 # 7 days
      )
      existing_session.update(refresh_token: refresh_token, expires_at: Time.now + (7 * 24 * 60 * 60))
    else
      # Generate a new session
      refresh_token = @jwt_manager.generate_jwt(
        user_id: user.id,
        username: user.username,
        exp_in_seconds: 7 * 24 * 60 * 60 # 7 days
      )
      session = Session.new(
        user_id: user.id,
        refresh_token: refresh_token,
        ip_address: ip_address,
        user_agent: user_agent,
        expires_at: Time.now + (7 * 24 * 60 * 60)
      )

      halt 500, { error: 'Failed to create session' }.to_json unless session.save
    end

    # Generate short-lived access token
    token = @jwt_manager.generate_jwt(
      user_id: user.id,
      username: user.username,
      exp_in_seconds: 60 * 1 * 1
    )

    # Respond with success
    halt 200, {
      message: 'Login successful',
      token: token,
      refresh_token: refresh_token
    }.to_json
  rescue Sequel::DatabaseError
    halt 500, { error: 'Database error occurred' }.to_json
  rescue StandardError => e
    halt 500, { error: 'An unexpected error occurred', details: e.message }.to_json
  end


  before '/api/logout' do
    authenticate_request!
  end
  post '/api/logout' do
    # Ensure the user is authenticated
    halt 401, { error: 'Unauthorized' }.to_json unless @current_user

    # Extract IP address and user agent from request payload
    ip_address = @request_payload[:ip_address] || request.ip
    user_agent = @request_payload[:user_agent] || request.user_agent

    # Find the current session
    current_session = Session.where(
      user_id: @current_user.id,
      ip_address: ip_address,
      user_agent: user_agent,
      revoked: false
    ).first

    # Handle missing session
    halt 404, { error: 'Session not found' }.to_json unless current_session

    # Revoke the session
    current_session.update(revoked: true)

    # Respond with success
    halt 200, { message: 'Logout successful' }.to_json
  end

  before '/api/user' do
    authenticate_request!
    puts "[DEBUG] Current server time: #{Time.now.utc}"
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
