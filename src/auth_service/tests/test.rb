#require './config/db_setup'
#require './auth_service'
# db = DBSetup.new('test')
# @db = db.db
require 'sequel'
db_connection = {
  adapter: 'postgres',
  host: 'localhost',
  database: 'auth_db',
  user: 'auth_user',
  password: 'securepassword'
}

begin
  db = Sequel.connect(db_connection)
  puts "Connection successful! Connected to database: #{db.opts[:database]} as user: #{db.opts[:user]}"
rescue Sequel::DatabaseConnectionError => e
  puts "Error connecting to database: #{e.message}"
end

users = db[:users]

# users.insert(
#   username: 'johndoe',
#   password_hash: 'hashed_password_123',
#   email: 'johndoe@example.com',
#   avatar: 'default_avatar.png'
# )
#
# users.insert(
#   username: 'janedoe',
#   password_hash: 'hashed_password_456',
#   email: 'janedoe@example.com',
#   avatar: 'profile_pic.jpg'
# )

# puts @db.tables # Output: [:users]
#
# users = @db[:users]
# puts user.count
# puts users.first
# puts users.where(username: 'johndoe').first
# puts users.all
#
# puts users.where(username: 'johndoe').first
# puts users.order(:id).all

class User < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:username, :password_hash, :email]
    validates_unique [:username, :email]
    validates_format /\A[^@\s]+@[^@\s]+\z/, :email, message: 'Email is not valid'
  end
end


# SEE! accessing User class globally without actually importing it!
puts User.first.inspect

user = User.new(username: 'johndoe', email: 'invalid_email')
unless user.valid?
  puts user.errors.full_messages
end