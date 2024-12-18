require 'sinatra'
require 'json'
require_relative 'config/database'
require_relative 'app/models/user'
require_relative 'app/services/user_registration_service'
require_relative 'app/controllers/user_controller'
require_relative 'app/validators/user_validator'


# Establish database connection when the app starts
# begin
#   Database.establish_connection
# rescue => e
#   puts "Could not start the application: #{e.message}"
#   exit(1)
# end

# In a migration script or console

require 'sequel'

# Run migrations on startup
# begin
#   Sequel.extension :migration
#   Sequel::Migrator.run(DB, 'db/migrations')
#   puts "Migrations completed successfully!"
# rescue => e
#   puts "Migration error: #{e.message}"
#   raise
# end



before do
  content_type :json
end

post '/api/users/register' do
  params = JSON.parse(request.body.read)
  UserController.register(params)
end