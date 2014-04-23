class AddDependenciesImportedColumnToCookbookVersions < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :dependencies_imported, :boolean, default: false
  end
end
