class AddDownloadCountToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :download_count, :integer, default: 0
  end
end
