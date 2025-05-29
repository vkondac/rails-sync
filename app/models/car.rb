class Car < ApplicationRecord
  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { greater_than: 1900 }
  validates :color, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Add sync tracking fields via migration
  # rails generate migration AddSyncFieldsToCars _status:string _changed:text last_modified_at:datetime
  
  before_save :update_sync_fields
  after_commit :log_sync_change

  scope :modified_since, ->(timestamp) { where('last_modified_at > ?', Time.at(timestamp / 1000.0)) }

  private

  def update_sync_fields
    self.last_modified_at = Time.current
    self._status = 'synced' if _status.blank?
    
    # Track changed fields
    if changed.any?
      self._changed = changed.join(',')
    end
  end

  def log_sync_change
    operation = if saved_change_to_id?
      'created'
    elsif destroyed?
      'deleted'
    else
      'updated'
    end

    SyncLog.create!(
      table_name: 'cars',
      record_id: id,
      operation: operation,
      timestamp: (Time.current.to_f * 1000).to_i,
      data: operation == 'deleted' ? nil : attributes.except('_status', '_changed')
    )
  end
end