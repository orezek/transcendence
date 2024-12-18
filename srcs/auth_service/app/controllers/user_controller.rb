
class UserController
  def self.register(params)
    service = UserRegistrationService.new(params)
    result = service.register

    if result[:success]
      [201, { user: result[:user].values.except(:password) }.to_json]
    else
      [422, { errors: result[:errors] }.to_json]
    end
  end
end