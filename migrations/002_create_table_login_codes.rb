Sequel.migration do
  change do
    create_table(:login_codes) do
      primary_key :id
      String :code, null: false, unique: true
      foreign_key :user_id, :users, null: false
      Integer :expired_at, null: false
      Integer :updated_at
      Integer :created_at
    end
  end
end
