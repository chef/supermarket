class CreateCookbookVersionPlatforms < ActiveRecord::Migration
  def change
    create_table :cookbook_version_platforms do |t|
      t.references :cookbook_version
      t.references :supported_platform
      t.timestamps
    end

    add_index :cookbook_version_platforms, [:cookbook_version_id, :supported_platform_id], unique: true, name: 'index_cvp_on_cvi_and_spi'
  end
end
