class SyncController < ApplicationController
  # Pull changes from server
  def pull
    last_pulled_at = params[:last_pulled_at].to_i
    schema_version = params[:schema_version]
    migration = params[:migration]

    Rails.logger.info "Pull sync requested - lastPulledAt: #{last_pulled_at}"

    begin
      changes = get_changes_since(last_pulled_at)
      timestamp = (Time.current.to_f * 1000).to_i

      Rails.logger.info "Returning changes: cars: #{changes[:cars].values.flatten.size} records"

      render json: {
        changes: changes,
        timestamp: timestamp
      }
    rescue => e
      Rails.logger.error "Pull sync error: #{e.message}"
      render json: { error: e.message }, status: 500
    end
  end

  # Push changes to server
  def push
    changes = params[:changes] || {}
    last_pulled_at = params[:last_pulled_at]

    Rails.logger.info "Push sync received: cars: #{changes.dig('cars')&.values&.flatten&.size || 0} records"

    begin
      Car.transaction do
        process_table_changes('cars', changes['cars']) if changes['cars']
      end

      render json: { success: true }
    rescue => e
      Rails.logger.error "Push sync error: #{e.message}"
      render json: { error: e.message }, status: 500
    end
  end

  # Replacement sync - return full dataset
  def replacement
    Rails.logger.info "Replacement sync requested"

    begin
      cars = Car.all.map do |car|
        car.attributes.except('_status', '_changed')
      end

      changes = {
        cars: {
          created: cars,
          updated: [],
          deleted: []
        }
      }

      render json: {
        changes: changes,
        timestamp: (Time.current.to_f * 1000).to_i
      }
    rescue => e
      Rails.logger.error "Replacement sync error: #{e.message}"
      render json: { error: e.message }, status: 500
    end
  end

  private

  def get_changes_since(last_pulled_at)
    changes = {
      cars: { created: [], updated: [], deleted: [] }
    }

    # Get all sync logs since last pull
    sync_logs = SyncLog.since_timestamp(last_pulled_at)
                      .for_table('cars')
                      .order(:timestamp)

    sync_logs.each do |log|
      case log.operation
      when 'deleted'
        changes[:cars][:deleted] << log.record_id
      when 'created', 'updated'
        # Get current record data
        car = Car.find_by(id: log.record_id)
        if car
          car_data = car.attributes.except('_status', '_changed')
          changes[:cars][log.operation.to_sym] << car_data
        end
      end
    end

    changes
  end

  def process_table_changes(table_name, table_changes)
    return unless table_changes

    model_class = table_name.classify.constantize

    # Handle created records
    (table_changes['created'] || []).each do |record_data|
      record_data = record_data.except('_status', '_changed')
      model_class.create!(record_data)
    end

    # Handle updated records
    (table_changes['updated'] || []).each do |record_data|
      record_data = record_data.except('_status', '_changed')
      record = model_class.find_by(id: record_data['id'])
      record&.update!(record_data.except('id'))
    end

    # Handle deleted records
    (table_changes['deleted'] || []).each do |record_id|
      record = model_class.find_by(id: record_id)
      record&.destroy!
    end
  end
end
