class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.measurement :integer
      t.measurement_types :jsonb

      t.timestamps
    end
  end
end
