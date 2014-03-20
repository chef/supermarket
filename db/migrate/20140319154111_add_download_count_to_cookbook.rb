class AddDownloadCountToCookbook < ActiveRecord::Migration
  def change
    add_column :cookbooks, :download_count, :integer, default: 0
  end
end
