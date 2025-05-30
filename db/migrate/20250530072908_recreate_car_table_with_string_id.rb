class RecreateCarTableWithStringId < ActiveRecord::Migration[7.1]
  def up
    # Save existing data
    existing_cars = Car.all.map(&:attributes)
    
    # Drop and recreate table with string ID
    drop_table :cars
    
    create_table :cars, id: false do |t|
      t.string :id, primary_key: true  # This is the key fix
      t.string :make, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.string :color, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :mileage, null: false
      t.string :_status, default: 'synced'
      t.text :_changed
      t.datetime :last_modified_at
      t.timestamps
    end
    
    # Restore data with proper string IDs
    existing_cars.each_with_index do |car_attrs, index|
      new_id = "car_#{Time.current.to_i + index}_#{SecureRandom.hex(4)}"
      Car.create!(
        id: new_id,
        make: car_attrs['make'],
        model: car_attrs['model'],
        year: car_attrs['year'],
        color: car_attrs['color'],
        price: car_attrs['price'],
        mileage: car_attrs['mileage']
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end