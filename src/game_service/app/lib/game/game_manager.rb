class GameManager
  attr_reader :games
  def initialize
    @games = {}
  end

  def create_game
    game_id = SecureRandom.uuid
    game = Game.new(game_id)  # Create new game instance
    @games[game_id] = game    # Store it in the hash
    game  # Return the game object, not just the ID
  end

  def get_game(game_id)
    @games[game_id]
  end

  def remove_game(game_id)
    @games.delete(game_id)
  end

  def update_all_games
    @games.values.each(&:update)
  end
end
# class GameManager
#   def initialize
#     @games = {}
#     @waiting_players = []
#   end
#
#   def create_game
#     game_id = SecureRandom.uuid
#     game = Game.new(game_id)
#     @games[game_id] = game
#     game
#   end
#
#   def get_game_for_player(ws)
#     @games.values.find { |game| game.players.key?(ws) }
#   end
#
#   def remove_player(ws)
#     # Remove from waiting list if present
#     @waiting_players.delete(ws)
#
#     # Remove from game if in one
#     game = get_game_for_player(ws)
#     if game
#       game.remove_player(ws)
#       # Clean up empty games
#       @games.delete(game.id) if game.players.empty?
#       notify_game_ended(game.players.keys)
#     end
#   end
#
#   def notify_waiting(ws)
#     ws.send({ status: 'waiting', message: 'Waiting for opponent...' }.to_json)
#   end
#
#   def notify_game_joined(ws, game_id)
#     ws.send({ status: 'joined', game_id: game_id, message: 'Game starting!' }.to_json)
#   end
#
#   def notify_game_ended(players)
#     players.each do |ws|
#       ws.send({ status: 'ended', message: 'Game ended. Opponent disconnected.' }.to_json)
#     end
#   end
#
#   def update_all_games
#     @games.values.each do |game|
#       game.update_game_state
#       game.game_state
#     end
#   end
# end