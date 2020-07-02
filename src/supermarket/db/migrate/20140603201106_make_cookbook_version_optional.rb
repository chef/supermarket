class MakeCookbookVersionOptional < ActiveRecord::Migration[4.2]
  def up
    change_column :supported_platforms, :cookbook_version_id, :integer, null: true
  end

  def down
    change_column :supported_platforms, :cookbook_version_id, :integer, null: false
  end
end
