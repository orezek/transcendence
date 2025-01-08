module PongGame
  class Application
    class << self
      def start
        load_dependencies
        setup_environment
        start_server
      end

      private

      def load_dependencies
        require 'em-websocket'
        require 'json'
        require 'securerandom'

        # Load all application files
        Dir[File.join(__dir__, 'lib/**/*.rb')].sort.each { |file| require file }
      end

      def setup_environment
        ENV['RACK_ENV'] ||= 'development'
      end

      def start_server
        server = WebsocketServer.new
        server.start
      end
    end
  end
end

PongGame::Application.start