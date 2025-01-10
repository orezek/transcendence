require 'sequel'
require 'bcrypt'
require 'securerandom'
# frozen_string_literal: true

# The `DbTableInitializer` class is responsible for:
#
# - Importing sample data into the database for testing purposes.
#
# This class is intended to help developers set up a test database environment for development,
# prototyping, or testing workflows that require pre-populated data.
#
# Usage:
#   initializer = DbTableInitializer.new(db)
#   initializer.setup_tables
#   initializer.import_test_data
class ImportData
  def initialize(path_to_file)
    @path_to_file = path_to_file
  end

  def connect_to_db
    connection = {
      adapter: 'postgres',
      host: 'localhost',
      database: 'auth_db',
      user: 'auth_user',
      password: 'securepassword',
      port: '5432'
    }
    Sequel.connect(connection)
  end

  def insert_users(db)
    users = db[:users]
    users.insert(username: 'johndoe', password_hash: BCrypt::Password.create('randomPass123'), email: 'johndoe@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'janedoe', password_hash: BCrypt::Password.create('securePass456'), email: 'janedoe@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'alice', password_hash: BCrypt::Password.create('alicePassword789'), email: 'alice@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'bob', password_hash: BCrypt::Password.create('bobSecure321'), email: 'bob@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'charlie', password_hash: BCrypt::Password.create('charlieStrong654'), email: 'charlie@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'dave', password_hash: BCrypt::Password.create('daveUnique987'), email: 'dave@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
    users.insert(username: 'eve', password_hash: BCrypt::Password.create('eveSecret123'), email: 'eve@example.com', avatar: "https://example.com/avatars/#{SecureRandom.hex(8)}.png")
  end

end