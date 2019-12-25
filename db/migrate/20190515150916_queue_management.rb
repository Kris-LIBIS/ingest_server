# frozen_string_literal: true

class QueueManagement < ActiveRecord::Migration[5.2]

  def change

    create_table :work_statuses do |t|
      t.string :name, null: false
      t.string :description
    end

    create_table :queues do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :active, null: false, default: true
    end

    create_table :workers do |t|
      t.string :host
      t.integer :port, limit: 2, unsigned: true
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    create_table :works do |t|
      t.references :queue, foreign_key: true, null: false
      t.integer :priority, limit: 2, null: false
      t.column :data, :jsonb, default: '{}'
      t.references :work_status, foreign_key: true, null: false
      t.references :worker, foreign_key: true, null: true
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
      t.column :lock_version, :integer, null: false, default: 0
    end

  end

end
