class IndexAccountsOnUidAndProvider < ActiveRecord::Migration[4.2]
  def change
    add_index :accounts, [:uid, :provider], unique: true
  end
end
