# frozen_string_literal: true

module Teneo
  module IngestServer
    class WorkStatus < DataModel::Base
      has_many :works
    end
  end
end