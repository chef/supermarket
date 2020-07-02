class MoveCookbookMaintainerAndDescriptionToCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    remove_column :cookbooks, :maintainer, :string
    remove_column :cookbooks, :description, :text

    add_column :cookbook_versions, :maintainer, :string
    add_column :cookbook_versions, :description, :text
  end
end
