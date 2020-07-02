class AddChefVersionsAndOhaiVersionsToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :chef_versions, :json
    add_column :cookbook_versions, :ohai_versions, :json
  end
end
