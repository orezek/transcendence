# frozen_string_literal: true

require 'sinatra'
set :bind, '0.0.0.0' # Bind to all interfaces

get '/' do
  status 200 # status
  'Status service'.to_json # response body
end

