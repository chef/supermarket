class LinkCookbookToCookbookDependency < ActiveRecord::Migration
  def change
    add_column :cookbook_dependencies, :cookbook_id, :integer
    add_index :cookbook_dependencies, :cookbook_id
  end
end
