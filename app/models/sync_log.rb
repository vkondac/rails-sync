class SyncLog < ApplicationRecord
  validates :table_name, presence: true
  validates :record_id, presence: true
  validates :operation, presence: true, inclusion: { in: %w[created updated deleted] }
  validates :timestamp, presence: true

  scope :since_timestamp, ->(timestamp) { where('timestamp > ?', timestamp) }
  scope :for_table, ->(table_name) { where(table_name: table_name) }
end
