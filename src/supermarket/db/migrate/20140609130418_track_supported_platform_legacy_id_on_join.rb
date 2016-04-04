class TrackSupportedPlatformLegacyIdOnJoin < ActiveRecord::Migration
  def change
    remove_index :supported_platforms, column: :legacy_id, unique: true
    remove_column :supported_platforms, :legacy_id, :integer
    add_column :cookbook_version_platforms, :legacy_id, :integer
    add_index :cookbook_version_platforms, :legacy_id, unique: true
  end
end
