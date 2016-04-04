class MakeContributorsUnique < ActiveRecord::Migration
  def change
    add_index :contributors, [:user_id, :organization_id], unique: true
  end
end
