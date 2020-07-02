class AddDependenciesImportedColumnToCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :dependencies_imported, :boolean, default: false
  end
end
