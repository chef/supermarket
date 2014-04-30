class AddUniqueConstraintToProviderAndUsername < ActiveRecord::Migration
  def change
    add_index :accounts, [:username, :provider], unique: true
  end
end
