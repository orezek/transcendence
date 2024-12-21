# frozen_string_literal: true

require 'sequel'
class DbHandler
  attr_reader :db

  def initialize(db_connection)
    @db = Sequel.connect(db_connection)
  end


  # db_connection = {
  #   adapter: 'postgres',
  #   host: 'db-service',
  #   database: 'auth_db',
  #   user: 'auth_user',
  #   password: 'securepassword'
  # }

  @db.
  # Create USERS table
  DB.create_table? :users do
    primary_key :id
    String :username, null: false, unique: true
    String :password_hash, null: false
    String :email, null: false, unique: true
    String :avatar
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  end
end
