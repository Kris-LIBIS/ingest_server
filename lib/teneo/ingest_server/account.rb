# frozen_string_literal: true
require 'securerandom'
require 'bcrypt'

# For performance reasons
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

require 'teneo/data_model/base'

module Teneo
  module IngestServer

    class Account < Teneo::DataModel::Base
      self.table_name = 'accounts'

      #noinspection RailsParamDefResolve
      belongs_to :user, foreign_key: 'email_id', class_name: 'Teneo::DataModel::User', primary_key: 'email'

      def self.authenticate(email, password)
        find_by(email_id: email)&.authenticate(password)
      end

      def password=(password)
        self.password_hash = BCrypt::Password.create(password)
        self.save!
      end

      def password
        BCrypt::Password.new(password_hash)
      end

      def authenticate(password)
        self.password == password && self
      end

      def self.find_for_jwt_authentication(sub)
        self.find_by(email: sub)
      end

      def jwt_subject
        self.email
      end

      def on_jwt_dispatch(token, payload)
        token[:jit] = self.jit = SecureRandom.base64(18)
        save!
      end

      def

    end
  end

  module DataModel

    class User

      #noinspection RailsParamDefResolve
      has_one :account, foreign_key: 'email_id', class_name: 'Teneo::IngestServer::Account', primary_key: 'email'

    end

  end

end

