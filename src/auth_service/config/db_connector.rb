# frozen_string_literal: true
require 'sequel'
require 'yaml'
class DbConnector
  attr_reader :db

  def initialize(env = 'development')
    @db_connection = load_config(env)
    @db = Sequel.connect(@db_connection)
  end

  private

  def load_config(env)
    YAML.load_file(File.join(__dir__,'./database.yml'))[env]
  end
  # def create_table
  #   # Create USERS table
  #   @db.create_table? :users do
  #     primary_key :id
  #     String :username, null: false, unique: true
  #     String :password_hash, null: false
  #     String :email, null: false, unique: true
  #     String :avatar
  #     DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  #     DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  #   end
  # end
end

# db_connection = {
#   adapter: 'postgres',
#   host: 'db-service',
#   database: 'auth_db',
#   user: 'auth_user',
#   password: 'securepassword'
# }
#
# db = DbConnector.new(db_connection)
# db.create_table
