# frozen_string_literal: true
require 'sequel'
require 'yaml'
class DbConnector
  attr_reader :db

  def initialize(env = 'development')
    @db_connection = load_config(env)
    @db = Sequel.connect(@db_connection)
  end

  private

  def load_config(env)
    YAML.load_file(File.join(__dir__,'./database.yml'))[env]
  end
end

