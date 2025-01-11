# frozen_string_literal: true

require 'sinatra'
require 'sinatra-websocket'

# Force Thin for better WebSocket support
set :server, 'thin'
set :bind, '0.0.0.0'
set :port, 4567
# Store active sockets
set :sockets, []

# -- Optional: Force logs to flush immediately so you see them in real time
$stdout.sync = true

# Log all requests before routing
before do
  puts "[DEBUG] Incoming request: #{request.request_method} #{request.path_info}"
  puts "[DEBUG] Is WebSocket handshake? -> #{request.websocket?}"
end

# Handle any exceptions that bubble up to Sinatra (outside WebSocket)
error do
  e = env['sinatra.error']
  puts "[ERROR] Sinatra caught an exception: #{e.class} - #{e.message}"
  e.backtrace.each { |line| puts line }
  "Error: #{e.message}"
end

# Basic HTTP route for sanity check
get '/' do
  puts "[DEBUG] Hit the '/' route, normal HTTP response"
  'Hello from Sinatra!'
end

# WebSocket route
get '/ws' do
  puts "[DEBUG] '/ws' route invoked"

  # Check if it's a proper WebSocket request
  unless request.websocket?
    puts "[DEBUG] Non-WebSocket request to '/ws'"
    halt 400, 'WebSocket handshake expected'
  end

  puts "[DEBUG] Proceeding with WebSocket handshake..."

  # Sinatra-WebSocket will now handle the handshake
  request.websocket do |ws|
    puts "[DEBUG] Entered request.websocket block. Setting up callbacks."

    # 1) onopen: Fired once the WebSocket is fully connected
    ws.onopen do
      begin
        puts "[WS] onopen triggered"
        settings.sockets << ws
        puts "[WS] Connected. Current total sockets: #{settings.sockets.count}"
      rescue => e
        puts "[WS][ERROR] Exception in onopen: #{e.message}"
        e.backtrace.each { |line| puts line }
      end
    end

    # 2) onmessage: Fired whenever the client sends a message
    ws.onmessage do |msg|
      begin
        puts "[WS] onmessage triggered: Received '#{msg}'"
        # Echo the message to all connected clients
        settings.sockets.each do |socket|
          socket.send("Echo: #{msg}")
        end
      rescue => e
        puts "[WS][ERROR] Exception in onmessage: #{e.message}"
        e.backtrace.each { |line| puts line }
      end
    end

    # 3) onclose: Fired when the client or server closes the connection
    ws.onclose do |code, reason|
      begin
        puts "[WS] onclose triggered: code=#{code.inspect}, reason=#{reason.inspect}"
        puts "[WS] Removing socket from settings.sockets..."
        settings.sockets.delete(ws)
        puts "[WS] Current total sockets after close: #{settings.sockets.count}"
      rescue => e
        puts "[WS][ERROR] Exception in onclose: #{e.message}"
        e.backtrace.each { |line| puts line }
      end
      puts "[WS] WebSocket disconnected"
    end

    # Note: sinatra-websocket doesn't officially expose an "onerror" callback,
    # so we rely on rescue blocks in onmessage/onopen to catch exceptions.
  end
rescue => e
  # Catch-all rescue for anything that might blow up above request.websocket
  puts "[DEBUG][RESCUE] Exception while setting up WebSocket: #{e.message}"
  e.backtrace.each { |line| puts line }
  halt 500, "WebSocket setup failure: #{e.message}"
end

