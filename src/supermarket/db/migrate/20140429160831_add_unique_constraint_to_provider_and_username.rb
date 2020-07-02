class AddUniqueConstraintToProviderAndUsername < ActiveRecord::Migration[4.2]
  def change
    add_index :accounts, [:username, :provider], unique: true
  end
end
