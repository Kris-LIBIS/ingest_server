# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

module Teneo
  module IngestServer

    class App < Roda

      Teneo::IngestServer::Database.instance
      plugin :public, root: 'static'
      plugin :empty_root
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :rodauth, csrf: false, json: :only do
        enable :login, :logout, :jwt
        account_password_hash_column :password_hash
        use_database_authentication_functions? false
        jwt_secret 'Teneo'
        #noinspection RubyResolve
        jwt_symbolize_deeply? true
      end

      route do |r|
        r.rodauth
        r.on 'api' do
          rodauth.require_authentication

          def current_user
            account = Teneo::IngestServer::Account.find(rodauth.session[:account_id])
            Teneo::DataModel::User.find_by(email: account.email)
          end

          r.get 'user' do
            ap rodauth.session
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
