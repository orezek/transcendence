class Game
attr_reader :game_id, :players

  def initialize(game_id, player1, player2)
    @game_id = game_id
    @players = {player1: player1, player2: player2}
  end

end
