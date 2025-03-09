class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.string :category
      t.integer :quantity
      t.text :description
      t.integer :remaining_quantity
      t.timestamps
    end
  end
end
