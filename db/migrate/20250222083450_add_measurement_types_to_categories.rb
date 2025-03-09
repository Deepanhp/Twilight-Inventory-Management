class AddMeasurementTypesToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :measurement_types, :json, default: []
  end
end
