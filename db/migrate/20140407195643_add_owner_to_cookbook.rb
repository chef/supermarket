class AddOwnerToCookbook < ActiveRecord::Migration
  def change
    add_column :cookbooks, :user_id, :integer
    add_index :cookbooks, :user_id
  end
end
