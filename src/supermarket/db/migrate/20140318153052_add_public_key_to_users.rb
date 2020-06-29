class AddPublicKeyToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :public_key, :text
  end
end
