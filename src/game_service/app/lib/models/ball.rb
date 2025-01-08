# lib/models/ball.rb
class Ball
  include GameConstants

  attr_reader :x, :y, :dx, :dy

  MAX_SPEED = 15
  BASE_SPEED = 5
  SPEED_INCREASE = 1.1

  def initialize(width, height)
    @width = width
    @height = height
    @speed = BASE_SPEED
    @moving = false
    reset
  end

  def move(delta_time)
    return unless @moving
    @x += @dx * @speed * delta_time * 60 # Normalize to 60 FPS
    @y += @dy * @speed * delta_time * 60
  end

  def reset
    @x = @width / 2
    @y = @height / 2
    @speed = BASE_SPEED
    @moving = false
    set_random_direction
  end

  def start_moving
    @moving = true
  end

  def bounce_vertical
    @dy *= -1
  end

  def bounce_horizontal(angle)
    @dx *= -1
    @dy = Math.sin(angle) * 1.5 # Add some vertical movement based on hit position
  end

  def increase_speed
    @speed = [@speed * SPEED_INCREASE, MAX_SPEED].min
  end

  def to_h
    {
      x: @x,
      y: @y,
      speed: @speed,
      moving: @moving
    }
  end

  private

  def set_random_direction
    angle = rand(-Math::PI/4..Math::PI/4) # Initial angle between -45 and 45 degrees
    direction = rand(2) == 0 ? 1 : -1 # Random horizontal direction

    @dx = direction * Math.cos(angle)
    @dy = Math.sin(angle)

    # Normalize the direction vector
    length = Math.sqrt(@dx * @dx + @dy * @dy)
    @dx /= length
    @dy /= length
  end
end