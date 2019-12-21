# frozen_string_literal: true

module Teneo
  module IngestServer
    class JobStatus < DataModel::Base
      has_many :jobs
    end
  end
end