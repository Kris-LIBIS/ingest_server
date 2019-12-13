# frozen_string_literal: true

require 'dotenv'
require 'erb'
require 'yaml'
require 'teneo-data_model'

Dotenv.load

db_config_file = ENV['DATABASE_CONFIG']
env = ENV['RUBY_ENV'] || 'development'
#noinspection RubyResolve
@db_config = YAML.load(ERB.new(File.read(db_config_file)).result)[env.to_s]

require 'sequel'
DB = Sequel.connect(
    adapter: 'postgres',
    user: @db_config['username'],
    password: @db_config['password'],
    host: @db_config['host'],
    port: @db_config['port'],
    database: @db_config['database'],
    max_connections: @db_config['pool'],
)
