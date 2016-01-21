class AddChefVersionAndOhaiVersionToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :chef_version, :json
    add_column :cookbook_versions, :ohai_version, :json
  end
end
