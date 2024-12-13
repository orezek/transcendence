require 'sinatra'
require 'json'
require 'pg' # PostgreSQL library

# Database connection helper
def connect_to_db
  PG.connect(
    host: 'db-service', # Service name in docker-compose.yml
    user: 'auth_user',        # As defined in POSTGRES_USER
    password: 'securepassword', # As defined in POSTGRES_PASSWORD
    dbname: 'auth_db'         # As defined in POSTGRES_DB
  )
end

# Get player information
get '/api/auth/player-info' do
  # Parse the player ID from query parameters
  player_id = params['id']&.to_i

  # Mock database lookup
  player = PLAYERS[player_id]

  if player
    # Player found, return as JSON
    content_type :json
    status 200
    player.to_json
  else
    # Player not found
    content_type :json
    status 404
    { error: 'Player not found' }.to_json
  end
end

# Welcome route
get '/' do
  { message: "Welcome to Transcendence" }.to_json
end

# Register a new user
post '/api/auth/register' do
  begin
    data = JSON.parse(request.body.read)

    # Extract data
    username = data['username']
    password = data['password']
    email = data['email']
    avatar = data['avatar']

    # Validate input - maybe not nesserary?
    errors = []
    errors << "Username must be under 16 characters" if username.nil? || username.length > 16
    errors << "Password must be under 32 characters" if password.nil? || password.length > 32
    errors << "Invalid email address" if email.nil? || !(email.match(/\A[^@\s]+@[^@\s]+\z/))
    errors << "Avatar must be provided" if avatar.nil?
    halt 400, { errors: errors }.to_json unless errors.empty?

    # Insert user into the database
    conn = connect_to_db
    result = conn.exec_params(
      "INSERT INTO users (username, password, email, avatar) VALUES ($1, $2, $3, $4) RETURNING id",
      [username, password, email, avatar]
    )

    user_id = result[0]['id'] # Get the generated ID

    status 201
    { message: "User registered successfully", user_id: user_id }.to_json

  rescue PG::Error => e
    halt 500, { error: e.message }.to_json
  rescue JSON::ParserError
    halt 400, { error: "Invalid JSON format" }.to_json
  ensure
    conn&.close
  end
end
