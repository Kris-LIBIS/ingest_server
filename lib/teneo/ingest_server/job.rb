# frozen_string_literal: true

module Teneo
  module IngestServer
    class Job < DataModel::Base
      belongs_to :job_status
      belongs_to :worker, optional: true
    end
  end
end