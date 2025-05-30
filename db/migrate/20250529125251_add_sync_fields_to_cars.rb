class AddSyncFieldsToCars < ActiveRecord::Migration[7.1]
  def change
    add_column :cars, :_status, :string
    add_column :cars, :_changed, :text
    add_column :cars, :last_modified_at, :datetime
  end
end
