class RemoveUnusedCookbookVersionsColumns < ActiveRecord::Migration
  def change
    remove_column :cookbook_versions, :file_size
    remove_column :cookbook_versions, :file_url
    remove_column :cookbook_versions, :maintainer
  end
end
