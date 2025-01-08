require_relative '../game/game_manager'

class WebsocketServer
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

      setup_game_loop
    end
  end

  private

  def setup_game_loop
    EventMachine.add_periodic_timer(1.0/GameConstants::UPDATE_RATE) do
      @game_manager.update_all_games
      broadcast_game_states
    end
  end

  def broadcast_game_states
    @game_manager.games.each_value do |game|
      GameStateBroadcaster.notify_game_state(game)
    end
  end
end