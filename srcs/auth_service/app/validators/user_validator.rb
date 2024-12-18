
class UserValidator
  def initialize(user)
    @user = user
  end

  def valid?
    @user.valid?
  end

  def errors
    @user.errors.full_messages
  end
end