class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :group_id
      t.integer :user_id
      t.boolean :admin

      t.timestamps
    end
  end
end
