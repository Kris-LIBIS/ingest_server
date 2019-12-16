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
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :json_parser

      route do |r|
        r.on 'api' do

          r.post 'login' do

          end

          def current_user
            #account = Teneo::IngestServer::Account.find(rodauth.session[:account_id])
            #account.user
          end

          r.get 'user' do
            { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
          end

          r.get 'organizations' do
            current_user.member_organizations.each_with_object([]) do |m, a|
              org = m[0]
              roles = m[1]
              a << {
                  id: org.id,
                  name: org.name,
                  roles: roles
              }
            end
          end

          r.get 'organization', Integer do |id|

            {name: name}
          end

        end
      end

    end

  end
end
