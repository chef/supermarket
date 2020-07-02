class AddIndexToCookbookAndCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_index :cookbooks, :name
    add_index :cookbook_versions, :version
  end
end
