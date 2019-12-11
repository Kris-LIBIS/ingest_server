# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

class IngestServer < Roda
  plugin :public, root: 'static'
  plugin :empty_root
  plugin :heartbeat, path: '/status'
  plugin :json
  plugin :rodauth

  route do |r|
  end
end
