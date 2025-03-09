class RemoveCategoryAndMeasurementCategory < ActiveRecord::Migration[7.2]
  def change
    remove_column :items, :category
    remove_column :items, :measurement_category
  end
end
