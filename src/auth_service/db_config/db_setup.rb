require_relative './db_connector'
require_relative 'db_table_initializer'

class DBSetup
  attr_reader :db

  def initialize(env = 'development')
    @db = setup_database(env)
    setup_tables
    load_models
  end

  private

  def setup_database(env)
    connector = DbConnector.new(env)
    connector.db
  end
  def setup_tables
    initializer = DbTableInitializer.new(@db)
    initializer.setup_tables
  end
  # dynamic import - funny and + it becomes globally accessible
  def load_models
    Dir[File.join(__dir__, '../models/*rb')].each { |file| require file }
  end
end