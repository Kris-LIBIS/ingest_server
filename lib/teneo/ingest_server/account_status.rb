# frozen_string_literal: true

module Teneo
  module IngestServer

    class AccountStatus < Teneo::DataModel::Base
      self.table_name = 'account_statuses'

      #noinspection RailsParamDefResolve
      has_many :users, foreign_key: 'status_id', class_name: 'Teneo::IngestServer::Account', primary_key: 'id'

    end

  end
end