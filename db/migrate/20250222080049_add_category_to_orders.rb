class AddCategoryToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :category, :string
  end
end
