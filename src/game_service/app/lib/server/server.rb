require_relative '../game/game_manager'

class Server
  def initialize
    @game_manager = GameManager.new
    @matchmaking = MatchmakingService.new(@game_manager)
    @connection_handler = ConnectionHandler.new(@matchmaking, @game_manager)
  end

  def start
    EventMachine.run do
      EventMachine::WebSocket.start(host: '0.0.0.0', port: 8080) do |ws|
        @connection_handler.handle(ws)
      end

      # REST API service
      Thin::Server.start('0.0.0.0', 4567, ApiEndpoints.new)

      setup_game_loop
    end
  end

  private

  def setup_game_loop
    EventMachine.add_periodic_timer(1.0/GameConstants::UPDATE_RATE) do
      @game_manager.update_all_games
      broadcast_player_states
    end
  end

  def broadcast_player_states
    @game_manager.games.each_value do |game|
      GameStateBroadcaster.notify_game_state(game)
    end
  end
end

# Using Sinatra for REST API
require 'sinatra'
require 'json'
class ApiEndpoints < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 4567

  def initialize
    super
  end

  post '/games/new_game' do
    content_type :json
    request_payload = JSON.parse(request.body.read)

    # Create game room logic here
    # room = GameRoom.new(
    #   player1_id: request_payload['player1_id'],
    #   player2_id: request_payload['player2_id']
    # )
    game_id = 999

    status 201
    { room_id: game_id }.to_json
  end
end