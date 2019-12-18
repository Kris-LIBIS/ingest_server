# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

module Teneo
  module IngestServer

    class App < Roda

      key = File.read(File.join(Teneo::IngestServer::ROOT_DIR, 'key.bin'), mode: 'rb')

      use Rack::Session::Cookie, secret: key

      plugin :public, root: 'static'
      plugin :empty_root
      plugin :multi_route
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :json_parser
      plugin :all_verbs
      plugin :halt
      plugin :sessions,
             cookie_options: { http_only: true, same_site: :strict },
             secret: key,
             key: 'teneo.ingester'

      route do |r|
        require_relative 'apps/user'
        require_relative 'apps/organization'

        r.on 'api' do

          r.post 'login' do
            account = Account.authenticate(r.params['email'], r.params['password'])
            user = account&.user
            r.halt(401) unless user
            session[:user_id] = user.uuid
            {
                name: user.name,
                orgs: user.member_organizations.each_with_object({}) do |(org, roles), hash|
                  hash[org.name] = { id: org.id, roles: roles }
                end
            }
          end

          def current_user
            @current_user ||= Teneo::DataModel::User.find_by(uuid: session[:user_id])
          end

          r.delete 'logout' do
            user = current_user
            session.clear
            {
                message: user ? "User #{user.name} logged out" : "Not logged in"
            }
          end

          r.halt(401) unless current_user

          r.on 'user' do
            r.route 'user'
          end

          r.on 'organizations' do
            r.route 'organizations'
          end

        end
      end

    end

  end
end
