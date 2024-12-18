
class UserRegistrationService
  def initialize(params)
    @params = params
    @user = User.new(@params)
  end

  def register
    validator = UserValidator.new(@user)

    if validator.valid?
      @user.save
      { success: true, user: @user }
    else
      { success: false, errors: validator.errors }
    end
  end
end