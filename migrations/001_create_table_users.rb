Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name
      String :email, unique: true, null: false
      Integer :updated_at
      Integer :created_at
    end
  end
end
