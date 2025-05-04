class AddMeasurementTypesToCategories < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:categories, :measurement_types)
      add_column :categories, :measurement_types, :json, default: []
    end
  end
end
