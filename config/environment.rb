# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'teneo-ingest_server'

#noinspection RubyResolve
Dir.glob('initializers/*.rb').each { |f| require_relative f }
