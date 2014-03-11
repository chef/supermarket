class EnsureUniqueCookbookVersions < ActiveRecord::Migration
  def change
    add_index :cookbook_versions, [:version, :cookbook_id], unique: true
  end
end
