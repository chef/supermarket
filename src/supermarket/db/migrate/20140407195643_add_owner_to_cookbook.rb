class AddOwnerToCookbook < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :user_id, :integer
    add_index :cookbooks, :user_id
  end
end
