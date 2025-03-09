class UpdateOrdersForMeasurementHandling < ActiveRecord::Migration[7.2]
  def change
    change_table :orders do |t|
      t.json :measurement_requested, default: {} # Stores requested length/volume dynamically
    end
  end
end
