# frozen_string_literal: true
require 'teneo-data_model'
require 'teneo-ingester'

ON_TTY=true
# dir = File.join Teneo::DataModel.root, 'db', 'seeds'
# Teneo::DataModel::SeedLoader.new(dir)
dir = File.join Teneo::Ingester::ROOT_DIR, 'db', 'seeds'
Teneo::Ingester::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds'
Teneo::DataModel::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'code_tables'
Teneo::DataModel::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'workflows'
Teneo::DataModel::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'kadoc'
Teneo::DataModel::SeedLoader.new(dir, tty: ON_TTY)

LoginUser.update_or_create({email: 'admin@libis.be'}, {password: 'abc123', password_confirmation: 'abc123'})
LoginUser.update_or_create({email: 'teneo@libis.be'}, {password: '123abc', password_confirmation: '126abc'})
