class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence %i[username password_hash email]
    validates_format /\A[^@\s]+@[^@\s]+\z/, :email, message: 'Email is not valid'

    # Custom uniqueness validation considering active users
    if User.where(username: username, active: true).exclude(id: id).first
      errors.add(:username, 'Active user with this username already exists')
    end

    if User.where(email: email, active: true).exclude(id: id).first
      errors.add(:email, 'Active user with this email already exists')
    end
  end
end
