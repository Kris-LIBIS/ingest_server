# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'teneo-ingest_server'

Teneo::IngestServer::Database.instance
Teneo::Ingester::Initializer.instance.database
