require 'net/http'
require 'json'
require 'uri'
class MatchmakingService
  def initialize(game_manager)
    @game_manager = game_manager
    @waiting_players = []
  end

  def handle_new_player(connection)
    if @waiting_players.any?
      create_game(connection, @waiting_players.shift)
    else
      add_to_waiting_list(connection)
      nil
    end
  end

  def handle_player_disconnect(connection)
    remove_player(connection)
  end

  def notify_players()
    @waiting_players.each do |player|
      GameStateBroadcaster.notify_waiting(player)
    end
  end

  private

  def add_to_waiting_list(connection)
    @waiting_players << connection
    GameStateBroadcaster.notify_waiting(connection)
  end

  def create_game(player1, player2)
    # URL for your game service (using Docker service name)
    uri = URI('http://game_service:4567/games/new_game')  # Adjust port as needed

    # Create request
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'

    # Set request body
    request.body = {
      player1_id: 1, #hardcoded, will be changed
      player2_id: 2, #hardcoded, will be changed
      created_at: Time.now
    }.to_json

    begin
      # Create HTTP client with timeout
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5
      http.open_timeout = 5

      # Send request
      response = http.request(request)

      case response
      when Net::HTTPSuccess
        game_data = JSON.parse(response.body)
        game = @game_manager.create_game(game_data['room_id'], player1, player2)
        GameStateBroadcaster.notify_game_found(game)
      else
        puts "Failed to create game: #{response.code} - #{response.message}"
        puts "Response body: #{response.body}"
        return nil
      end
    rescue => e
      puts "Error creating game: #{e.message}"
      return nil
    end
  end

  def remove_player(connection)
    @waiting_players.delete(connection)
  end
end






# # Usage example:
# game_id = create_game("player123", "player456")
# if game_id
#   puts "Game created with ID: #{game_id}"
# else
#   puts "Failed to create game"
# end