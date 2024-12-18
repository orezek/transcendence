require 'sequel'
require 'logger'
module DatabaseConfig
  def self.connect
    Sequel.connect(
      adapter: 'postgres',
      host: ENV['DB_HOST'] || 'db-service',
      database: ENV['DB_NAME'] || 'auth_db',
      user: ENV['DB_USER'] || 'auth_user',
      password: ENV['DB_PASSWORD'] || 'securepassword',
      logger: Logger.new($stdout)
    )
  end
end

# Global database connection
DB = DatabaseConfig.connect