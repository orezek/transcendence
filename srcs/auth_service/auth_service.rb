require 'sinatra'
require 'json'

# Mock database of players
PLAYERS = {
  1 => { id: 1, name: 'm_sulc', score: 1200 },
  2 => { id: 2, name: 'm_bartos', score: 201 }
}

# Get player information
get '/api/auth/player-info' do
  # Parse the player ID from query parameters
  player_id = params['id']&.to_i

  # Lookup the player in the mock database
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
