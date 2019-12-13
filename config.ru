# frozen_string_literal: true
require 'dotenv'
#noinspection RubyArgCount
Dotenv.load

require './ingest_server'

run IngestServer.freeze.app