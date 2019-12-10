# frozen_string_literal: true
require 'dotenv'
Dotenv.load

require './ingest_server'

run IngestServer.freeze.app