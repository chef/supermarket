class CreateCookbookFollowers < ActiveRecord::Migration
  def change
    create_table :cookbook_followers do |t|
      t.integer :cookbook_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :cookbook_followers, [:cookbook_id, :user_id], unique: true
  end
end
