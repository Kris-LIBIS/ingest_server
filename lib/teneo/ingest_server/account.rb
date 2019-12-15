# frozen_string_literal: true
require 'teneo/data_model/base'
require 'bcrypt'

# For performance reasons
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

module Teneo
  module IngestServer

    class Account < Teneo::DataModel::Base
      self.table_name = 'accounts'

      #noinspection RailsParamDefResolve
      belongs_to :user, foreign_key: 'email_id', class_name: 'Teneo::DataModel::User', primary_key: 'email'
      belongs_to :status, foreign_key: 'status_id', class_name: 'Teneo::IngestServer::AccountStatus', primary_key: 'id'

      def self.authenticate(email, password)
        find_by(email_id: email)&.authenticate(password)
      end

      def password=(password)
        self.password_hash = BCrypt::Password.create(password)
      end

      def password
        BCrypt::Password.new(password_hash)
      end

      def authenticate(password)
        self.password == password && self
      end

    end
  end

  module DataModel

    class User

      #noinspection RailsParamDefResolve
      has_one :account, foreign_key: 'email_id', class_name: 'Teneo::IngestServer::Account', primary_key: 'email'

    end

  end

end

