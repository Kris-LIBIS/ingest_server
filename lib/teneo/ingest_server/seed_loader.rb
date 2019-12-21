# frozen_string_literal: true

module Teneo
  module IngestServer

    class SeedLoader < Teneo::DataModel::SeedLoader

      def load
        super
        load_data :job_status
      end

      def string_to_class(klass_name)
        "Teneo::IngestServer::#{klass_name.to_s.classify}".constantize
        rescue NameError
          super
      end

    end

  end
end
