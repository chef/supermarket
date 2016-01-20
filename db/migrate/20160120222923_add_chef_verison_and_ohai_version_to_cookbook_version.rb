class AddChefVerisonAndOhaiVersionToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :chef_version, :string
    add_column :cookbook_versions, :ohai_version, :string
  end
end
