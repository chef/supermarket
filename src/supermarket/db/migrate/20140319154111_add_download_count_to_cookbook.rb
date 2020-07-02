class AddDownloadCountToCookbook < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :download_count, :integer, default: 0
  end
end
