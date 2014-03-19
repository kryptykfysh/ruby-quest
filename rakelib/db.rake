require 'rake'
require 'yaml'
require 'active_record'
require 'sqlite3'
require_relative '../lib/ruby_quest'
require_relative '../db/seeds.rb'

include ActiveRecord::Tasks
include SeedLoader

DatabaseTasks.database_configuration = YAML.load(
  File.read(
    File.join(APP_PATH, 'config/database.yml')
  )
)
DatabaseTasks.db_dir = File.join(APP_PATH, 'db')
DatabaseTasks.migrations_paths = File.join(DatabaseTasks.db_dir, 'migrations')
DatabaseTasks.seed_loader = Loader.new
DatabaseTasks.env = ENV['ENVIRONMENT'] || 'development'
ActiveRecord::Base.configurations = DatabaseTasks.database_configuration

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env
end
 
load 'active_record/railties/databases.rake'
