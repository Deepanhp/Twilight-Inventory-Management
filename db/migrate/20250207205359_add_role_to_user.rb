class AddRoleToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role_type, :string
  end
end
