# frozen_string_literal: true
require 'dotenv'
#noinspection RubyArgCount
Dotenv.load

require_relative 'config/environment'

require 'warden/manager'
require 'warden/jwt_auth/middleware'

use Warden::JWTAuth::Middleware

use Warden::Manager do |manager|
  manager.default_strategies(:jwt)
  manager.failure_app = ->(_env) { [401, {}, ['unauthorized']] }
end

run Teneo::IngestServer::App.app
