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
        require 'thin'

        # Load all application files
        Dir[File.join(__dir__, 'lib/**/*.rb')].sort.each { |file| require file }
      end

      def setup_environment
        ENV['RACK_ENV'] ||= 'development'
      end

      def start_server
        server = Server.new
        server.start
        puts 'Server started!'
        puts ' -> REST API running on port 4567'
        puts ' -> WebSocket running on port 8080'
      end
    end
  end

Application.start
