# frozen_string_literal: true

module Teneo
  module IngestServer
    class Worker < DataModel::Base
      has_many :works
    end
  end
end
