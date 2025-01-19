require_relative '../game/game'
class MatchmakingService
  def initialize(game_manager)
    @game_manager = game_manager
    @waiting_players = []
  end

  def handle_new_player(connection)
    if @waiting_players.any?
      create_game_with_players(connection, @waiting_players.shift)
    else
      add_to_waiting_list(connection)
    end
  end

  def handle_player_disconnect(connection)
    remove_player(connection)
  end

  private

  def add_to_waiting_list(connection)
    @waiting_players << connection
    GameStateBroadcaster.notify_waiting(connection)
  end

  def create_game_with_players(player1, player2)
    game = @game_manager.create_game
    puts 'after rest api call of game service'
    game.add_player(player1, :player1)
    game.add_player(player2, :player2)
    GameStateBroadcaster.notify_game_started(game)
  end

  def remove_player(connection)
    @waiting_players.delete(connection)
  end
end