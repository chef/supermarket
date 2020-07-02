class TrackWebDownloadCounts < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :web_download_count, :integer, default: 0
    add_column :cookbook_versions, :web_download_count, :integer, default: 0
  end
end
