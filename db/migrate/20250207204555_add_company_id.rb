class AddCompanyId < ActiveRecord::Migration[7.2]
  def change
    add_reference :items, :company, foreign_key: true
    add_reference :users, :company, foreign_key: true
    add_reference :members, :company, foreign_key: true
    add_reference :orders, :company, foreign_key: true
  end
end
