class CreateVerifiedCookbookVersions < ActiveRecord::Migration
  def change
    create_table :verified_cookbook_versions do |t|
      t.integer :cookbook_version_id, null: false

      t.timestamps
    end

    add_index :verified_cookbook_versions, :cookbook_version_id, unique: true
  end
end
