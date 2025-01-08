class GameStateBroadcaster
  class << self
    def notify_waiting(connection)
      send_message(connection, {
        status: 'waiting',
        message: 'Waiting for opponent...'
      })
    end

    def notify_game_started(game)
      game.players.values.each do |player|
        send_message(player.connection, {
          status: 'game_started',
          game_id: game.id,
          player_id: player.id,  # Added player_id
          role: player.role,     # Added role
          message: 'Game starting!'
        })
      end
    end

    def notify_game_state(game)
      return unless game.game_started

      game.players.values.each do |player|
        send_message(player.connection, {
          status: 'game_update',
          game_state: game.game_state
        })
      end
    end

    def notify_game_over(connection, data)
      send_message(connection, {
        status: 'game_over',
        winner_id: data[:winner_id],
        final_scores: data[:final_scores],
        message: 'Game Over!'
      })
    end

    private

    def send_message(connection, data)
      connection.send(data.to_json)
    end
  end
end
