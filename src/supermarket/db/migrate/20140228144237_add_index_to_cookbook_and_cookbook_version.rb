class AddIndexToCookbookAndCookbookVersion < ActiveRecord::Migration
  def change
    add_index :cookbooks, :name
    add_index :cookbook_versions, :version
  end
end
