class CreateSyncLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_logs do |t|
      t.string :table_name, null: false
      t.string :record_id, null: false
      t.string :operation, null: false
      t.bigint :timestamp, null: false
      t.text :data

      t.timestamps
    end

    # Add indexes for better performance during sync operations
    add_index :sync_logs, :timestamp
    add_index :sync_logs, [:table_name, :timestamp]
    add_index :sync_logs, :record_id
    add_index :sync_logs, [:table_name, :record_id]
    add_index :sync_logs, :operation
  end
end