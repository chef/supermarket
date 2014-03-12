class AddPublicKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_key, :text
  end
end
