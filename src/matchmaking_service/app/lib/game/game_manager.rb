class GameManager
  attr_reader :games
  def initialize
    @games = {}
  end

  def create_game(game_id, player1, player2)
    @games[game_id] = Game.new(game_id, player1, player2)    # Store it in the hash
  end

  def get_game(game_id)
    @games[game_id]
  end

  def remove_game(game_id)
    @games.delete(game_id)
  end

end