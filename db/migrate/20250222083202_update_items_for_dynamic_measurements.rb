class UpdateItemsForDynamicMeasurements < ActiveRecord::Migration[7.2]
  def change
    change_column_default :items, :measurements, from: nil, to: {}
  end
end
