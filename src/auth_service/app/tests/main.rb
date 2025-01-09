#require './config/db_setup'
#require './auth_service'
require_relative './import_data'
require_relative '' './connect'
# db = DBSetup.new('test')
# @db = db.db
# require 'sequel'
# db_connection = {
#   adapter: 'postgres',
#   host: 'localhost',
#   database: 'auth_db',
#   user: 'auth_user',
#   password: 'securepassword'
# }
#
# begin
#   db = Sequel.connect(db_connection)
#   puts "Connection successful! Connected to database: #{db.opts[:database]} as user: #{db.opts[:user]}"
# rescue Sequel::DatabaseConnectionError => e
#   puts "Error connecting to database: #{e.message}"
# end
#
# users = db[:users]

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

# class User < Sequel::Model
#   plugin :validation_helpers
#   def validate
#     super
#     validates_presence [:username, :password_hash, :email]
#     validates_unique [:username, :email]
#     validates_format /\A[^@\s]+@[^@\s]+\z/, :email, message: 'Email is not valid'
#   end
# end
#
#
# # SEE! accessing User class globally without actually importing it!
# puts User.first.inspect
#
# user = User.new(username: 'johndoe', email: 'invalid_email')
# unless user.valid?
#   puts user.errors.full_messages
# end
# import_data = ImportData.new('path/to_file.csv')
# db = import_data.connect_to_db
# import_data.insert_users(db)
#
# user = db[:users].where(id: 5).first # return hash = row of user data
#
# puts user.class
# puts user.methods
# user.each { |key, value| puts "#{key}: #{value}" }
#
# puts user.keys[2].class
# puts user.values[0].class
#
# puts db[:users].class
# users = db[:users]
# puts users.class
#
# puts users.where{email.startswith('bob')}.all
# db[:users].each { |row| row.each { |key, value| puts "#{key}: #{value}" } }

def greet(name)
  puts "Hello, #{name}!"
end

greet("John")

def greet_block
  puts "printing block"
  puts "Hello, block!"
  yield
end

greet_block do
  puts "Test"
  puts "ahoj"
end

greet_block {puts "single line block"}

arr = [1,2,3]
arr.each {|n| puts n * 10}
new_arr = arr.map do |n|
  result = n * 10
  result    # make sure to return the value you want in the new array
end
puts new_arr.class

puts MAGIC_VALUE