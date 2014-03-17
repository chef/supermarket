class RemoveDescriptionFromCookbookVersions < ActiveRecord::Migration
  def change
    remove_column :cookbook_versions, :description, :text
  end
end
