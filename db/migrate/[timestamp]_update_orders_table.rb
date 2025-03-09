class UpdateOrdersTable < ActiveRecord::Migration[7.0]
  def change
    # Remove columns that are now in order_items
    remove_column :orders, :quantity, :integer
    remove_column :orders, :item_id, :integer
  end
end 