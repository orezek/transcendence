require_relative 'game_constants'
require_relative 'game_manager'

class Game
  include GameConstants

  attr_reader :id, :players, :scores, :game_started

  def initialize(id)
    @id = id
    @players = {}
    @ball = Ball.new(CANVAS_WIDTH, CANVAS_HEIGHT)
    @scores = { player1: 0, player2: 0 }
    @game_started = false
    @last_update = Time.now
  end

  def add_player(connection, role)
    return false if full?

    player = Player.new(connection, role)
    @players[player.id] = player
    @game_started = @players.size == 2

    if @game_started
      reset_ball
    end

    player
  end

  def remove_player(player_id)
    @players.delete(player_id)
    @game_started = false
    reset_game
  end

  def full?
    @players.size >= 2
  end

  def update
    return unless @game_started

    delta_time = calculate_delta_time
    update_ball(delta_time)
    check_collisions
    check_scoring
  end

  def move_paddle(player_id, direction)
    return unless @players[player_id]
    @players[player_id].move(direction)
  end

  def game_state
    {
      game_id: @id,
      ball: @ball.to_h,
      players: players_state,
      scores: @scores,
      game_started: @game_started
    }
  end

  private

  def calculate_delta_time
    current_time = Time.now
    delta = current_time - @last_update
    @last_update = current_time
    delta
  end

  def update_ball(delta_time)
    @ball.move(delta_time)
    handle_wall_collisions
  end

  def handle_wall_collisions
    if @ball.y <= 0 || @ball.y >= CANVAS_HEIGHT
      @ball.bounce_vertical
    end
  end

  def check_collisions
    check_paddle_collisions(:player1)
    check_paddle_collisions(:player2)
  end

  def check_paddle_collisions(player_role)
    player = find_player_by_role(player_role)
    return unless player

    paddle_x = player_role == :player1 ? PADDLE_WIDTH : CANVAS_WIDTH - PADDLE_WIDTH
    paddle_y = player.position

    if ball_collides_with_paddle?(paddle_x, paddle_y)
      handle_paddle_collision(player_role, paddle_y)
    end
  end

  def ball_collides_with_paddle?(paddle_x, paddle_y)
    ball_rect = {
      x: @ball.x - BALL_SIZE/2,
      y: @ball.y - BALL_SIZE/2,
      width: BALL_SIZE,
      height: BALL_SIZE
    }

    paddle_rect = {
      x: paddle_x - PADDLE_WIDTH/2,
      y: paddle_y - PADDLE_HEIGHT/2,
      width: PADDLE_WIDTH,
      height: PADDLE_HEIGHT
    }

    rectangles_collide?(ball_rect, paddle_rect)
  end

  def rectangles_collide?(rect1, rect2)
    rect1[:x] < rect2[:x] + rect2[:width] &&
      rect1[:x] + rect1[:width] > rect2[:x] &&
      rect1[:y] < rect2[:y] + rect2[:height] &&
      rect1[:y] + rect1[:height] > rect2[:y]
  end

  def handle_paddle_collision(player_role, paddle_y)
    # Calculate relative impact point (-1 to 1)
    relative_intersect_y = (@ball.y - paddle_y) / (PADDLE_HEIGHT / 2)
    # Normalize to keep angle within reasonable bounds
    bounce_angle = relative_intersect_y * Math::PI / 4

    if player_role == :player1
      @ball.bounce_horizontal(bounce_angle)
    else
      @ball.bounce_horizontal(-bounce_angle)
    end

    # Increase ball speed slightly with each paddle hit
    @ball.increase_speed
  end

  def check_scoring
    if @ball.x <= 0
      score_point(:player2)
    elsif @ball.x >= CANVAS_WIDTH
      score_point(:player1)
    end
  end

  def score_point(player_role)
    @scores[player_role] += 1
    if game_over?
      handle_game_over
    else
      reset_ball
    end
  end

  def game_over?
    @scores.values.any? { |score| score >= 10 } # Win at 10 points
  end

  def handle_game_over
    @game_started = false
    broadcast_game_over
  end

  def broadcast_game_over
    winner_role = @scores[:player1] > @scores[:player2] ? :player1 : :player2
    winner = find_player_by_role(winner_role)

    @players.each do |_, player|
      GameStateBroadcaster.notify_game_over(player.connection, {
        winner_id: winner&.id,  # Handle potential nil winner
        final_scores: @scores
      })
    end
  end

  # def broadcast_game_over
  #   winner_role = @scores[:player1] > @scores[:player2] ? :player1 : :player2
  #   winner = find_player_by_role(winner_role)
  #
  #   @players.each do |_, player|
  #     GameStateBroadcaster.notify_game_over(player.connection, {
  #       winner_id: winner.id,
  #       final_scores: @scores
  #     })
  #   end
  # end

  def reset_ball
    @ball.reset
    # Add a small delay before the ball starts moving
    EventMachine.add_timer(1.5) do
      @ball.start_moving if @game_started
    end
  end

  def reset_game
    @ball.reset
    @scores = { player1: 0, player2: 0 }
    @game_started = false
  end

  def find_player_by_role(role)
    @players.values.find { |player| player.role == role }
  end

  def players_state
    @players.transform_values(&:to_h)
  end
end