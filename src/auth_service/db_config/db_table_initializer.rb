# frozen_string_literal: true

# The `DbTableInitializer` class is responsible for initializing the necessary database tables.
# It creates the `users` and `sessions` tables if they do not already exist.
#
# Usage:
#   initializer = DbTableInitializer.new(db)
#   initializer.setup_tables
class DbTableInitializer
  def initialize(db)
    @db = db
  end

  def setup_tables
    create_users_table
    create_user_sessions_table
  end

  private

  def create_users_table
    @db.create_table? :users do
      primary_key :id
      String :username, null: false, unique: false
      String :password_hash, null: false
      String :email, null: false, unique: false
      String :avatar
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      Boolean :active, default: true
    end
  end

  def create_user_sessions_table
    @db.create_table? :sessions do
      primary_key :id
      foreign_key :user_id, :users, null: false # connect sessions
      String :refresh_token, size: 255
      Inet :ip_address
      String :user_agent, size: 512
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :expires_at, default: Sequel.lit("(CURRENT_TIMESTAMP + interval '7 days')")
      Boolean :revoked, default: false
    end
  end
end