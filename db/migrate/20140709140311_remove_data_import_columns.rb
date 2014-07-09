class RemoveDataImportColumns < ActiveRecord::Migration
  def change
    %w(
      cookbook_collaborators
      cookbook_followers
      cookbook_version_platforms
      cookbooks
      users
    ).each do |table|
      remove_index table, column: :legacy_id, unique: true
      remove_column table, :legacy_id, :integer
    end

    remove_index :cookbook_versions, :verification_state
    remove_column :cookbook_versions, :verification_state, :string, default: 'pending', null: false
  end
end
