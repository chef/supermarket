class EnsureUniqueCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    add_index :cookbook_versions, [:version, :cookbook_id], unique: true
  end
end
