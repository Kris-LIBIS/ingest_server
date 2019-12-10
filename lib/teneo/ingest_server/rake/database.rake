namespace :teneo do
    namespace :db do

        desc 'Create database password schema'
        task create_pwd_schema: 'teneo:db:environment' do
            if @db_config['pwd_schema']
                ActiveRecord::Base.establish_connection(@db_config_dba)
                conn = ActiveRecord::Base.connection
                schema_name = @db_config['data_schema']
                schema_pwd = @db_config['pwd_schema']
                user = @db_config['username']
                pwd_user = @db_config['pwd_user']
                conn.execute("CREATE SCHEMA \"#{schema_pwd}\" AUTHORIZATION #{pwd_user}")
                conn.execute("GRANT USAGE ON SCHEMA \"#{schema_pwd}\" TO \"#{user}\"")
                conn.execute("GRANT USAGE ON SCHEMA \"#{schema_name}\" TO \"#{pwd_user}\"")
            end
        end

        Rake::Task['teneo:db:create'].enhance do
            Rake::Task['teneo:db:create_pwd_schema'].invoke
        end

        desc 'Drop database password schema'
        task drop_pwd_schema: 'teneo:db:environment' do
            if @db_config['pwd_schema']
                ActiveRecord::Base.establish_connection(@db_config_dba)
                conn = ActiveRecord::Base.connection
                schema_pwd = @db_config['pwd_schema']
                conn.drop_schema(schema_pwd, if_exists: true)
            end
        end

        Rake::Task['teneo:db:drop'].enhance ['teneo:db:drop_pwd_schema']
        
    end
end