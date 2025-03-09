class AddCategoryIdToItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :items, :category, foreign_key: true
  end
end
