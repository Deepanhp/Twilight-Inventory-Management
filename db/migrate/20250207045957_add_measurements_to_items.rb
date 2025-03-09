class AddMeasurementsToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :measurement_category, :string # Renamed to avoid conflicts
    add_column :items, :measurements, :jsonb, default: {}
  end
end
