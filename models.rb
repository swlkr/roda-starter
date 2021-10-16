require 'sequel'
require 'logger'

# DATABASE
DB = Sequel.connect ENV.fetch('DATABASE_URL')

DB.loggers << Logger.new($stdout)

# set pragma stuff
DB.run 'PRAGMA busy_timeout=5000;'
DB.run 'PRAGMA synchronous=NORMAL;'
DB.run 'PRAGMA foreign_keys=1;'
DB.run 'PRAGMA journal_mode=WAL;'

# MIGRATE
Sequel.extension :migration
Sequel::Migrator.run(DB, 'migrations')

# MODELS
Model = Class.new(Sequel::Model(DB))
# set_fields doesn't set existing models' columns to nil
Model.default_set_fields_options[:missing] = :skip
Model.def_Model(self)

Model.plugin :dataset_associations
Model.plugin :auto_validations, not_null: :presence
Model.plugin :timestamps
Model.plugin :dataset_associations
Model.plugin :string_stripper
Model.plugin :association_proxies
Model.plugin :hash_id, salt: ENV.fetch('HASH_ID_SALT').freeze, length: 7
Model.plugin :validation_helpers
Model.plugin :forme

Dir[File.join(__dir__, 'models', '*.rb')].each do |file|
  require file
end

DB.freeze
