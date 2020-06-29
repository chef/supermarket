class RemoveDescriptionFromCookbookVersions < ActiveRecord::Migration[4.2]
  def change
    remove_column :cookbook_versions, :description, :text
  end
end
