class TrackApiDownloadCounts < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :api_download_count, :integer, default: 0
    add_column :cookbook_versions, :api_download_count, :integer, default: 0
  end
end
