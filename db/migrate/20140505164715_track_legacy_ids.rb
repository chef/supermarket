class TrackLegacyIds < ActiveRecord::Migration
  def change
    change_table :cookbook_versions do |t|
      t.integer :legacy_id
    end

    change_table :users do |t|
      t.integer :legacy_id
    end

    change_table :supported_platforms do |t|
      t.integer :legacy_id
    end

    change_table :cookbooks do |t|
      t.integer :legacy_id
    end

    change_table :cookbook_collaborators do |t|
      t.integer :legacy_id
    end

    change_table :cookbook_followers do |t|
      t.integer :legacy_id
    end

    add_index :cookbook_versions, :legacy_id, unique: true
    add_index :users, :legacy_id, unique: true
    add_index :supported_platforms, :legacy_id, unique: true
    add_index :cookbooks, :legacy_id, unique: true
    add_index :cookbook_collaborators, :legacy_id, unique: true
    add_index :cookbook_followers, :legacy_id, unique: true
  end
end
