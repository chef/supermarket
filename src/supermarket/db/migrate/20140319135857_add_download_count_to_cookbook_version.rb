class AddDownloadCountToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :download_count, :integer, default: 0
  end
end
