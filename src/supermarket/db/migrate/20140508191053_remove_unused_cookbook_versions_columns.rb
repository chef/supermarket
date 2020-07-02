class RemoveUnusedCookbookVersionsColumns < ActiveRecord::Migration[4.2]
  def change
    remove_column :cookbook_versions, :file_size
    remove_column :cookbook_versions, :file_url
    remove_column :cookbook_versions, :maintainer
  end
end
