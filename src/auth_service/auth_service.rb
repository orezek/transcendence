require 'sinatra'
require 'json'
require 'pg'
require 'sequel'
require 'bcrypt'
require_relative 'jwt_manager'

class AuthService < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 4567
  def initialize
    super
    @jwt_manager = JwtManager.new
  end

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


  db_connection = {
    adapter: 'postgres',
    host: 'db-service',
    database: 'auth_db',
    user: 'auth_user',
    password: 'securepassword'
  }
  DB = Sequel.connect(db_connection)

  # Create USERS table
  DB.create_table? :users do
    primary_key :id
    String :username, null: false, unique: true
    String :password_hash, null: false
    String :email, null: false, unique: true
    String :avatar
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  end

  # User model
  class User < Sequel::Model
    plugin :validation_helpers

    def validate
      super
      validates_presence [:username, :password_hash, :email]
      validates_unique :username, message: 'Username is already taken'
      validates_unique :email, message: 'Email is already registered'
      validates_format /\A[^@\s]+@[^@\s]+\z/, :email, message: 'Email is not valid'
    end
  end

  # Middleware to parse JSON body
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

  before do
    puts "Received request: #{request.request_method} #{request.path}"
  end
  # Register API route
  post '/api/register' do
    puts "Received request: #{request.request_method} #{request.path}"
    user_data = {
      username: @request_payload[:username],
      password_hash: BCrypt::Password.create(@request_payload[:password]),
      email: @request_payload[:email],
      avatar: @request_payload[:avatar] || '/images/default-avatar.png'
    }
    # Just testing incoming data
    puts "Testing input"
    if user_data[:username].to_s.empty?
      puts 'empty username field'
    end
    puts user_data[:password_hash]
    puts user_data[:email]
    puts user_data[:avatar]
    puts "End of testing input -----"
    user = User.new(user_data)

    begin
      if user.valid?
        user.save
        status 201
        { message: 'User registered successfully' }.to_json
      else
        status 400
        { errors: user.errors.full_messages }.to_json
      end
    rescue Sequel::UniqueConstraintViolation => e
      # Handle database-level uniqueness violations
      status 409
      error_field = e.message.include?('username') ? 'username' : 'email'
      { error: "#{error_field.capitalize} is already taken" }.to_json
    end
  end


  post '/api/login' do
    begin
      content_type :json
      puts "Processing login request..."

      username = @request_payload[:username]
      password = @request_payload[:password]
      puts "Received username: #{username}"
      puts "Received password: #{password}"

      # Halt if username or password is missing
      halt 400, { error: 'Username and password are required' }.to_json unless username && password

      # Fetch the user from the database
      user = User.where(username: username).first
      puts "Fetched user: #{user.inspect}"

      # Validate the password
      if user && BCrypt::Password.new(user.password_hash) == password
        puts "Password validated successfully"
        # Generate JWT token
        #token = generate_jwt({ user_id: user.id, username: user.username })
        token = @jwt_manager.generate_jwt(user_id: user.id, username: user.username)
        status 200
        { message: 'Login successful', token: token }.to_json
      else
        puts "Invalid username or password"
        status 401
        { error: 'Invalid username or password' }.to_json
      end
    rescue => e
      puts "An error occurred: #{e.message}"
      puts e.backtrace.join("\n")
      status 500
      { error: 'Internal Server Error' }.to_json
    end
  end

  before '/api/user' do
    authenticate_request!
  end
  get '/api/user' do
    puts 'Testing user info'
    puts @current_user[:username]
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
