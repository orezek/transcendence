class User < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:username, :password_hash, :email]
    validates_unique :username, message: 'Username is already taken'
    validates_unique :email, message: 'Email is already registered'
    validates_format /\A[^@\s]+@[^@\s]+\z/, :email, message: 'Email is not valid'
  end
end