# frozen_string_literal: true

require 'teneo-ingest_server'
require 'bcrypt'

ON_TTY = false
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

Teneo::IngestServer::AccountStatus.create_with(name: 'Undefined').find_or_create_by(id: 1)
Teneo::IngestServer::AccountStatus.create_with(name: 'Verified').find_or_create_by(id: 2)
Teneo::IngestServer::AccountStatus.create_with(name: 'Closed').find_or_create_by(id: 3)

Teneo::IngestServer::Account.create_with(password: 'abc123').find_or_create_by(email_id: 'Admin@libis.be')
Teneo::IngestServer::Account.create_with(password: '123abc').find_or_create_by(email_id: 'Info@kadoc.be')
