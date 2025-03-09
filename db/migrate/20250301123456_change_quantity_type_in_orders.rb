class ChangeQuantityTypeInOrders < ActiveRecord::Migration[7.0]
  def up
    # First, create temporary column
    add_column :orders, :quantity_int, :integer

    # Update the temporary column with converted values
    Order.reset_column_information
    Order.find_each do |order|
      order.update_columns(
        quantity_int: order.quantity.to_i
      )
    end

    # Remove old column
    remove_column :orders, :quantity

    # Rename new column to original name
    rename_column :orders, :quantity_int, :quantity
  end

  def down
    change_column :orders, :quantity, :string
  end
end 