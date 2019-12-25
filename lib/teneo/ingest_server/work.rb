# frozen_string_literal: true

module Teneo
  module IngestServer

    class Work < DataModel::Base

      belongs_to :job_status
      belongs_to :worker, optional: true

      def self.from_hash(hash, id_tags = [])
        queue_name = hash.delete(:queue_name)
        query = queue_name ? {name: queue_name} : {id: hash[:queue_id]}
        queue = record_finder Teneo::IngestServer::Queue, query
        hash[:queue_id] = queue.id
        super(hash, id_tags)
      end

    end

  end
end