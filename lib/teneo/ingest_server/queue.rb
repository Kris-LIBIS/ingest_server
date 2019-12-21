# frozen_string_literal: true

module Teneo
  module IngestServer
    class Queue < DataModel::Base
      has_many :jobs
    end
  end
end