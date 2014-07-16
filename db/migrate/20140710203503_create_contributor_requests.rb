class CreateContributorRequests < ActiveRecord::Migration
  def change
    create_table :contributor_requests do |t|
      t.integer :organization_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :contributor_requests, [:organization_id, :user_id], unique: true
  end
end
