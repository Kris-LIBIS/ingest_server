# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'
require_relative 'db'

class IngestServer < Roda
  plugin :public, root: 'static'
  plugin :empty_root
  plugin :heartbeat, path: '/status'
  plugin :json
  plugin :rodauth, csrf: false, json: :only do
    enable :login, :logout, :jwt
    function_name do |name|
      "#{@db_config[:pwd_schema]}.#{name}"
    end
    password_hash_table Sequel[@db_config[:pwd_schema].to_sym][:account_password_hashes]
  end

  route do |r|
  end
end
