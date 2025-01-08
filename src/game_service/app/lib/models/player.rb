class Player
  attr_reader :id, :position, :role, :connection

  def initialize(connection, role)
    @id = SecureRandom.uuid
    @connection = connection
    @role = role
    @position = GameConstants::CANVAS_HEIGHT / 2
  end

  def move(direction)
    new_pos = @position + direction * GameConstants::PADDLE_SPEED
    @position = [
      [new_pos, GameConstants::PADDLE_HEIGHT/2].max,
      GameConstants::CANVAS_HEIGHT - GameConstants::PADDLE_HEIGHT/2
    ].min
  end

  def to_h
    {
      position: @position,
      role: @role
    }
  end
end
