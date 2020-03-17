# frozen_string_literal: true

namespace :teneo do
  namespace :db do

    desc 'Create database schema'
    task create_schema: 'teneo:db:environment' do
      if (schema_name = @db_config['data_schema'])
        ActiveRecord::Base.establish_connection(@db_config)
        conn = ActiveRecord::Base.connection
        conn.execute("CREATE SCHEMA \"#{schema_name}\" AUTHORIZATION #{@db_config['username']}")
        puts "Database Schema #{schema_name} created."
        ActiveRecord::Base.connection.close
      end
    end

    desc 'Drop database schema'
    task drop_schema: 'teneo:db:environment' do
      if (schema_name = @db_config['username'])
        ActiveRecord::Base.establish_connection(@db_config)
        conn = ActiveRecord::Base.connection
        conn.drop_schema(schema_name, if_exists: true)
        puts "Database Schema #{schema_name} deleted."
        ActiveRecord::Base.connection.close
      end
    rescue ActiveRecord::NoDatabaseError
      puts "Database #{@db_config['database']} does not exist."
    end

    desc 'Create the database'
    task create: 'teneo:db:create_schema' do
      # do not create the database, only create the schema
    end

    desc 'Drop the database'
    task drop: 'teneo:db:drop_schema' do
      # do not drop the database, drop the schema instead
    end

  end
end
