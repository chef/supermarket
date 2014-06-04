class EnsurePlatformUniqueness < ActiveRecord::Migration
  def up
    add_index :supported_platforms, [:name, :version_constraint], unique: true
    remove_column :supported_platforms, :cookbook_version_id
  end

  def down
    add_column :supported_platforms, :cookbook_version_id, :integer
    remove_index :supported_platforms, [:name, :version_constraint]
  end
end
