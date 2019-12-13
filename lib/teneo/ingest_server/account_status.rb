# frozen_string_literal: true

module Teneo
  module IngestServer
    class AccountStatus < Teneo::DataModel::Base
      self.table_name = 'account_statuses'
    end
  end
end