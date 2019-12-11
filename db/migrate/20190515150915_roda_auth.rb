# frozen_string_literal: true

class RodaAuth < ActiveRecord::Migration[5.2]

  def change

    create_table :account_statuses do |t|
      t.string :name, null: false
      t.index :name, unique: true
    end

    create_table :accounts do |t|
      t.references :account_statuses, foreign_key: :status_id
      t.citext :email, null: false
      t.index :email, unique: true, where: 'status_id IN (1, 2)'
    end

    # Used by the password reset feature
    create_table :account_password_reset_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
      t.datetime :email_last_sent, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the jwt refresh feature
    create_table :account_jwt_refresh_keys do |t|
      t.references :accounts
      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
    end

    # Used by the account verification feature
    create_table :account_verification_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.datetime :requested_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :email_last_sent, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the verify login change feature
    create_table :account_login_change_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.string :login, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
    end

    # Used by the remember me feature
    create_table :account_remember_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '14 days'" }
    end

    # Used by the lockout feature
    create_table :account_login_failures, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.integer :number, null: false, default: 1
    end

    create_table :account_lockouts, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
      t.datetime :email_last_sent
    end

    # Used by the email auth feature
    create_table :account_email_auth_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.datetime :deadline, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
      t.datetime :email_last_sent, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the password expiration feature
    create_table :account_password_change_times, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.datetime :changed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the account expiration feature
    create_table :account_activity_times, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.datetime :last_activity_at, null: false
      t.datetime :last_login_at, null: false
      t.datetime :expired_at
    end

    # Used by the single session feature
    create_table :account_session_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
    end

    # Used by the otp feature
    create_table :account_otp_keys, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :key, null: false
      t.integer :num_failures, null: false, default: 0
      t.datetime :last_use, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # Used by the recovery codes feature
    create_table :account_recovery_codes, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.string :code
      t.index [:id, :code], unique: true, null: false

    end

    # Used by the sms codes feature
    create_table :account_sms_codes, primary_key: false do |t|
      t.references :accounts, foreign_key: :id
      t.index :id, unique: true, null: false

      t.string :phone_number, null: false
      t.integer :num_failures
      t.string :code
      t.datetime :code_issued_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

  end

end
