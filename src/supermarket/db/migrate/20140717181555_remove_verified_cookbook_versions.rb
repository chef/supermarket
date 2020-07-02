class RemoveVerifiedCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    if table_exists?(:verified_cookbook_versions)
      drop_table :verified_cookbook_versions
    end
  end
end
