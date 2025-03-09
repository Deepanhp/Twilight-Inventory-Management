class AddLengthAndBreadthToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :length, :float
    add_column :orders, :breadth, :float
  end
end
