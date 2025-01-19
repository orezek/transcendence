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

      setup_queue_loop

      # REST API service
      Thin::Server.start('0.0.0.0', 4567, ApiEndpoints.new)
    end
  end

  private

  def setup_queue_loop
    EventMachine.add_periodic_timer(1.0) do
      broadcast_player_states
    end
  end

  def broadcast_player_states
    @matchmaking.notify_players
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

  # post '/matchmaking/new_game' do
  #   content_type :json
  #   request_payload = JSON.parse(request.body.read)
  #
  #   # Create game room logic here
  #   # room = GameRoom.new(
  #   #   player1_id: request_payload['player1_id'],
  #   #   player2_id: request_payload['player2_id']
  #   # )
  #   room_id = 999
  #
  #   status 201
  #   { room_id: room_id }.to_json
  # end
end