# frozen_string_literal: true

require 'singleton'
require 'dotenv'
require 'erb'
require 'yaml'
require 'teneo-data_model'
require 'sequel'

module Teneo
  module IngestServer
    class Database
      include Singleton

      attr_reader :db_config, :db

      protected

      def initialize
        #noinspection RubyArgCount
        Dotenv.load
        db_config_file = ENV['DATABASE_CONFIG']
        env = ENV['RUBY_ENV'] || 'development'
        #noinspection RubyResolve
        @db_config = YAML.load(ERB.new(File.read(db_config_file)).result)[env.to_s]
        @db = Sequel.connect(
            adapter: 'postgres',
            user: @db_config['username'],
            password: @db_config['password'],
            host: @db_config['host'],
            port: @db_config['port'],
            database: @db_config['database'],
            max_connections: @db_config['pool'],
            )
      end
    end
  end
end
