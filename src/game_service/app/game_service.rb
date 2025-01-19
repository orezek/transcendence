module PongGame
  class Application
    class << self
      def start
        load_dependencies
        setup_environment
        start_server
      end

      private

      def load_dependencies
        require 'em-websocket'
        require 'json'
        require 'securerandom'
        require 'thin'

        # Load all application files
        Dir[File.join(__dir__, 'lib/**/*.rb')].sort.each { |file| require file }
      end

      def setup_environment
        ENV['RACK_ENV'] ||= 'development'
      end

      def start_server
        server = Server.new
        server.start
        puts 'Both servers started!'
        puts ' -> REST API running on port 4567'
        puts ' -> WebSocket running on port 8080'
      end
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

PongGame::Application.start