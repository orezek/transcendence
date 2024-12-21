class DbTableInitializer
  def initialize(db)
    @db = db
  end

  def setup_tables
    create_users_table
    #add more as you need
  end

  private

  def create_users_table
    @db.create_table? :users do
      primary_key :id
      String :username, null: false, unique: true
      String :password_hash, null: false
      String :email, null: false, unique: true
      String :avatar
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end