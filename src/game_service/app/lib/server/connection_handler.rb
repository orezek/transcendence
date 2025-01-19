class ConnectionHandler
  def initialize(matchmaking, game_manager)
    @matchmaking = matchmaking
    @game_manager = game_manager
  end

  def handle(ws)
    ws.onopen { handle_connection(ws) }
    ws.onmessage { |msg| handle_message(ws, msg) }
    ws.onclose { handle_disconnection(ws) }
  end

  private

  def handle_connection(ws)
    puts "Client connected"
    @matchmaking.handle_new_player(ws)
  end

  def handle_message(ws, msg)
    data = JSON.parse(msg)
    case data['action']
    when 'move'
      handle_move(ws, data)
    end
  end

  def handle_move(ws, data)
    direction = data['direction']
    # Find the game this player is in and move their paddle
    player_game = find_player_game(ws)
    if player_game
      player = find_player(ws, player_game)
      player_game.move_paddle(player.id, direction) if player
    end
  end

  def handle_disconnection(ws)
    puts "Client disconnected"
    player_game = find_player_game(ws)
    if player_game
      player = find_player(ws, player_game)
      player_game.remove_player(player.id) if player
    end
    @matchmaking.handle_player_disconnect(ws)
  end

  private

  def find_player_game(ws)
    @game_manager.games.values.find do |game|
      game.players.values.any? { |player| player.connection == ws }
    end
  end

  def find_player(ws, game)
    game.players.values.find { |player| player.connection == ws }
  end
end