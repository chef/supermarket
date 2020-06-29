class MakeContributorsUnique < ActiveRecord::Migration[4.2]
  def change
    add_index :contributors, [:user_id, :organization_id], unique: true
  end
end
