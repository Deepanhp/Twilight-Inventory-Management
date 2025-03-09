class UpdateItemsForMeasurementHandling < ActiveRecord::Migration[7.2]
  def change
    change_table :items do |t|
      t.references :sub_category, foreign_key: true
      t.string :measurement_unit
    end
  end
end
