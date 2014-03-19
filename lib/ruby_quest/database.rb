# encoding: UTF-8

require 'active_record'
require 'yaml'

environment = ENV['ENVIRONMENT'] || 'development'
db_config = YAML.load(File.read('config/database.yml'))[environment]

ActiveRecord::Base.establish_connection(db_config)
