class Session < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:user_id, :refresh_token, :ip_address, :user_agent]
  end
end