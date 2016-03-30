class RemoveVerifiedCookbookVersions < ActiveRecord::Migration
  def change
    if table_exists?(:verified_cookbook_versions)
      drop_table :verified_cookbook_versions
    end
  end
end
