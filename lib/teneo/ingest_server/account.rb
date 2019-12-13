# frozen_string_literal: true
require 'teneo/data_model/base'

module Teneo
  module IngestServer
    class Account < Teneo::DataModel::Base
      self.table_name = 'accounts'

    end
  end
end