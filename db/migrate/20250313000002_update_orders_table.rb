class UpdateOrdersTable < ActiveRecord::Migration[7.0]
  def change
    # First check if columns exist before trying to remove them
    if column_exists?(:orders, :quantity)
      remove_column :orders, :quantity, :integer
    end
    
    if column_exists?(:orders, :item_id)
      remove_column :orders, :item_id, :integer
    end
  end
end 