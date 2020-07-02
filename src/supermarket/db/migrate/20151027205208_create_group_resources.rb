class CreateGroupResources < ActiveRecord::Migration[4.2]
  def change
    create_table :group_resources do |t|
      t.integer :group_id
      t.integer :resourceable_id
      t.string :resourceable_type

      t.timestamps
    end
  end
end
