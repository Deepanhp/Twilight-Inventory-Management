class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :measurement
      t.jsonb :measurement_types

      t.timestamps
    end
  end
end
