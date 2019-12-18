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
      plugin :all_verbs
      plugin :halt
      plugin :sessions,
             cookie_options: { http_only: true, same_site: :strict },
             secret: key,
             key: 'teneo.ingester'

      route do |r|

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

          # @return [Teneoo::IngestServer::Accout]
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

            r.is do
              { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
            end

          end

          r.on 'organizations' do

            user_orgs = current_user.member_organizations

            r.is do
              user_orgs.each_with_object([]) do |(org, roles), arr|
                arr << {
                    id: org.id,
                    name: org.name,
                    roles: roles
                }
              end
            end

            r.get Integer do |id|
              r.halt(401) unless (org = user_orgs.keys.find { |o| o.id == id })
              session[:org_id] = org.id
              {
                  name: org.name,
                  description: org.description,
                  code: org.inst_code
              }
            end

          end

          # @return [Teneo::DataModel::Organization]
          def current_organization
            @current_organization ||= Teneo::DataModel::Organization.find_by(id: session[:org_id])
          end

          r.on 'ingest_agreements' do

            org_agreements = current_organization&.ingest_agreements

            r.is do
              org_agreements.each_with_object([]) do |agr, arr|
                arr << {
                    id: agr.id,
                    name: agr.name,
                    description: agr.description,
                }
              end
            end

            r.get Integer do |id|
              r.halt(401) unless (agr = org_agreements.find_by(id: id))
              session[:agr_id] = agr.id
              {
                  id: agr.id,
                  name: agr.name,
                  description: agr.description,
                  project_name: agr.project_name,
                  collection_name: agr.collection_name,
                  collection_description: agr.collection_description,
                  contact_ingest: agr.contact_ingest,
                  contact_collection: agr.contact_collection,
                  contact_system: agr.contact_system,
              }
            end

          end

        end

      end

    end

  end
end
