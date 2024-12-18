require 'bcrypt'
require 'sequel'

unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :email, unique: true
    String :password
    DateTime :created_at
    DateTime :updated_at
  end
end
class User < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps

  def validate
    super
    validates_presence [:email, :password]
    validates_unique :email
    validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email
  end

  def password=(new_password)
    self[:password] = BCrypt::Password.create(new_password)
  end

  def valid_password?(password)
    return false if self[:password].nil?
    BCrypt::Password.new(self[:password]) == password
  end
end
