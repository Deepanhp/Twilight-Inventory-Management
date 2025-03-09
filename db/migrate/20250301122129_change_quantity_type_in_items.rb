class ChangeQuantityTypeInItems < ActiveRecord::Migration[7.0]
  def up
    # First, create temporary columns
    add_column :items, :quantity_int, :integer
    add_column :items, :remaining_quantity_int, :integer

    # Update the temporary columns with converted values
    Item.reset_column_information
    Item.find_each do |item|
      item.update_columns(
        quantity_int: item.quantity.to_i,
        remaining_quantity_int: item.remaining_quantity.to_i
      )
    end

    # Remove old columns
    remove_column :items, :quantity
    remove_column :items, :remaining_quantity

    # Rename new columns to original names
    rename_column :items, :quantity_int, :quantity
    rename_column :items, :remaining_quantity_int, :remaining_quantity
  end

  def down
    change_column :items, :quantity, :string
    change_column :items, :remaining_quantity, :string
  end
end
