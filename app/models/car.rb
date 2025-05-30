class Car < ApplicationRecord
  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { greater_than: 1900 }
  validates :color, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :update_sync_fields
  before_destroy :log_deletion  # Add this
  after_commit :log_sync_change, on: [:create, :update]  # Specify when to log

  scope :modified_since, ->(timestamp) { 
    if column_names.include?('last_modified_at')
      where('last_modified_at > ?', Time.at(timestamp / 1000.0))
    else
      where('updated_at > ?', Time.at(timestamp / 1000.0))
    end
  }

  private

  def update_sync_fields
    if respond_to?(:last_modified_at=)
      self.last_modified_at = Time.current
      self._status = 'synced' if respond_to?(:_status) && _status.blank?
      
      if changed.any? && respond_to?(:_changed=)
        self._changed = changed.join(',')
      end
    end
  end

  def log_deletion
    # Log deletion BEFORE the record is destroyed
    SyncLog.create!(
      table_name: 'cars',
      record_id: id,
      operation: 'deleted',
      timestamp: (Time.current.to_f * 1000).to_i,
      data: nil
    )
  rescue => e
    Rails.logger.error "Failed to create deletion sync log: #{e.message}"
  end

  def log_sync_change
    return unless defined?(SyncLog)
    return unless ActiveRecord::Base.connection.table_exists?('sync_logs')
    
    operation = if saved_change_to_id?
      'created'
    else
      'updated'
    end

    SyncLog.create!(
      table_name: 'cars',
      record_id: id,
      operation: operation,
      timestamp: (Time.current.to_f * 1000).to_i,
      data: attributes.except('_status', '_changed')
    )
  rescue => e
    Rails.logger.error "Failed to create sync log: #{e.message}"
  end
end