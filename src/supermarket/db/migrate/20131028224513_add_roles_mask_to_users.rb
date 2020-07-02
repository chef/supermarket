class AddRolesMaskToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :roles_mask, :integer
  end
end
