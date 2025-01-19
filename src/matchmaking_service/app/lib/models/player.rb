class Player
attr_reader :id, :connection

  def initialize(connection, role)
    @id = SecureRandom.uuid # Will be id from JWT token
    @connection = connection
  end
end
