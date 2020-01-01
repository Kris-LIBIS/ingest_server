# frozen_string_literal: true

require 'teneo-data_model'
require 'teneo-ingester'

module Teneo
  module IngestServer
    ROOT_DIR = File.expand_path('../..' , __dir__)
    RAKEFILE = File.join(File.expand_path(__dir__), 'ingest_server', 'rake', 'Rakefile')

    autoload :Account, 'teneo/ingest_server/account'
    autoload :App, 'teneo/ingest_server/app'
    autoload :SeedLoader, 'teneo/ingest_server/seed_loader'

  end
end