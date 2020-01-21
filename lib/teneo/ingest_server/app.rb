# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

module Teneo
  module IngestServer

    class App < Roda

      ROLE = 'ingester'.freeze

      key = File.read(File.join(Teneo::IngestServer::ROOT_DIR, 'key.bin'), mode: 'rb')

      use Rack::Session::Cookie, secret: key

      plugin :public, root: 'static'
      plugin :empty_root
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :json_parser
      plugin :all_verbs
      plugin :halt
      plugin :request_headers
      plugin :sessions,
             cookie_options: { http_only: true, same_site: :strict },
             secret: key,
             key: 'teneo.ingester'

      route do |r|

        r.on 'api' do

          r.halt 406, 'Unsupported Accept header value' unless r.headers['Accept'] =~ %r{^application/json}
          r.halt 405, 'Unsupported Content-Type header value' unless r.headers['Content-Type'] =~ %r{^application/json}

          r.post 'login' do
            account = Account.authenticate(r.params['email'], r.params['password'])
            user = account&.user
            r.halt 401 unless user
            session.clear
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

          r.halt 401 unless current_user

          r.on 'user' do

            r.is do
              { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
            end

          end

          r.on 'organizations' do

            r.is do
              current_user.organizations_for(ROLE).each_with_object([]) do |(org, roles), arr|
                arr << {
                    id: org.id,
                    name: org.name,
                    roles: roles
                }
              end
            end

            r.on Integer do |id|

              org = Teneo::DataModel::Organization.find_by(id: id)
              r.halt(404) unless org
              r.halt(401) unless current_user.is_authorized?(ROLE, org)

              r.is 'agreements' do
                agreements = org.ingest_agreements

                agreements.each_with_object([]) do |agr, arr|
                  arr << {
                      id: agr.id,
                      name: agr.name,
                      description: agr.description,
                  }
                end
              end

              r.get do
                {
                    name: org.name,
                    description: org.description,
                    code: org.inst_code
                }
              end

            end

          end

          r.on 'agreements' do

            r.is do
              org_id = r.params['org_id']
              r.halt 412, [{ error: 'Missing org_id' }] unless org_id
              organization = Teneo::DataModel::Organization.find_by(id: org_id)
              r.halt 412, [{ error: 'Organization not found' }] unless organization
              r.halt 401 unless current_user.is_authorized?(ROLE, organization)

              organization.ingest_agreements.each_with_object([]) do |agr, arr|
                arr << {
                    id: agr.id,
                    name: agr.name,
                    description: agr.description,
                }
              end
            end

            r.on Integer do |id|
              agreement = Teneo::DataModel::IngestAgreement.find_by(id: id)
              r.halt 404 unless agreement
              r.halt 401 unless current_user.is_authorized?(ROLE, agreement)

              r.get 'workflows' do
                agreement.ingest_workflows.map do |workflow|
                  {
                      id: workflow.id,
                      name: workflow.name
                  }
                end
              end

              r.get 'packages' do
                agreement.packages.each_with_object([]) do |package, arr|
                  arr << {
                      id: package.id,
                      name: package.name,
                      workflow: package.ingest_workflow.name
                  }
                end
              end

              r.is do
                {
                    name: agreement.name,
                    description: agreement.description,
                    project_name: agreement.project_name,
                    collection_name: agreement.collection_name,
                    collection_description: agreement.collection_description,
                    contact_ingest: agreement.contact_ingest,
                    contact_collection: agreement.contact_collection,
                    contact_system: agreement.contact_system,
                }
              end

            end

          end

          r.on 'workflows' do

            r.is do
              agr_id = r.params['agr_id']
              r.halt 412, [{ error: 'Missing agr_id' }] unless agr_id
              agreement = Teneo::DataModel::IngestAgreement.find_by(id: agr_id)
              r.halt 412, [{ error: 'Agreement not found' }] unless agreement
              r.halt 401 unless current_user.is_authorized?(ROLE, agreement)

              agreement.ingest_workflows.map do |workflow|
                {
                    id: workflow.id,
                    name: workflow.name
                }
              end
            end

            r.on Integer do |id|
              workflow = Teneo::DataModel::IngestWorkflow.find_by(id: id)
              r.halt 404 unless workflow
              r.halt 401 unless current_user.is_authorized?(ROLE, workflow)

              r.get 'packages' do
                workflow.packages.map do |package|
                  {
                      id: package.id,
                      name: package.name,
                      workflow: package.ingest_workflow.name
                  }
                end
              end

              r.is do
                {
                    name: workflow.name,
                    description: workflow.description,
                    stages: workflow.ingest_stages.each_with_object({}) do |stage, hash|
                      hash[stage.name] = {
                          id: stage.id,
                          autorun: stage.autorun,
                          name: stage.stage_workflow.name,
                          description: stage.stage_workflow.description
                      }
                    end
                }
              end

            end


          end

          r.on 'packages' do

            r.is do

              if (flow_id = r.params['flow_id'])
                workflow = Teneo::DataModel::IngestWorkflow.find_by(id: flow_id)
                r.halt 412, [{ error: 'Workflow not found' }] unless workflow
                r.halt 401 unless current_user.is_authorized?(ROLE, workflow)
                workflow
              elsif (agr_id = r.params['agr_id'])
                agreement = Teneo::DataModel::IngestAgreement.find_by(id: agr_id)
                r.halt 412, [{ error: 'Agreement not found' }] unless agreement
                r.halt 401 unless current_user.is_authorized?(ROLE, agreement)
                agreement
              else
                r.halt 412, [{ error: 'Missing agr_id or flow_id' }]
              end.packages.map do |package|
                {
                    id: package.id,
                    name: package.name,
                    workflow: package.ingest_workflow.name,
                }
              end
            end

            r.on Integer do |id|
              package = Teneo::DataModel::Package.find_by(id: id)
              r.halt 404 unless package
              r.halt 401 unless current_user.is_authorized?(ROLE, package)

              r.get 'runs' do
                package.runs.map do |run|
                  {
                      id: run.id,
                      name: run.name,
                      status: run.last_status.to_s
                  }
                end
              end

              r.post do
                case r.params['action']
                when 'start'
                  queue = Teneo::Ingester::Queue.find_by(id: r.params['queue_id'])
                  queue ||= Teneo::Ingester::Queue.find_by(name: r.params['queue_name'])
                  priority = r.params['priority'] || 100
                  r.halt(412) unless queue
                  run = package.make_run
                  work = Teneo::Ingester::Work.create(
                      queue: queue, priority: priority, subject: run, action: 'start',
                      work_status: Teneo::Ingester::WorkStatus.find_by(name: 'new')
                  )
                  {
                      work_id: work.id,
                      package_id: package.id,
                      run_id: run.id,
                      action: 'start'
                  }
                else
                  r.halt(400)
                end
              end

              r.is do
                {
                    id: package.id,
                    name: package.name,
                    workflow: {
                        id: package.ingest_workflow.id,
                        name: package.ingest_workflow.name
                    },
                    options: package.options,
                    parameters: package.parameter_values.transform_keys { |key| key.gsub(/^.*#/, '') }
                }
              end

            end

          end

          r.on 'runs' do

            r.is do
              pkg_id = r.params['pkg_id']
              r.halt 412, [{ error: 'Missing pkg_id' }] unless pkg_id
              package = Teneo::DataModel::Package.find_by(id: pkg_id)
              r.halt 412, [{ error: 'Agreement not found' }] unless package
              r.halt 401 unless current_user.is_authorized?(ROLE, package)

              package.runs.map do |run|
                {
                    id: run.id,
                    name: run.name,
                    status: run.last_status.to_s
                }
              end
            end

            r.on Integer do |id|
              run = Teneo::DataModel::Run.find_by(id: id)
              r.halt 404 unless run
              r.halt 401 unless current_user.is_authorized?(ROLE, run)

              r.is do
                {
                    id: run.id,
                    name: run.name,
                    start: run.start_date&.strftime('%Y/%m/%d %H:%M:%S.%L'),
                    config: run.config,
                    options: run.options,
                    properties: run.properties,
                    status: run.last_status.to_s
                }
              end

            end
          end

        end

      end

    end

  end
end
