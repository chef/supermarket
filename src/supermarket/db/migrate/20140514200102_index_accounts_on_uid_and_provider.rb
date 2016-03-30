class IndexAccountsOnUidAndProvider < ActiveRecord::Migration
  def change
    add_index :accounts, [:uid, :provider], unique: true
  end
end
