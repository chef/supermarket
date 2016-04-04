class AddCategoryIdToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :category_id, :integer
    remove_column :cookbooks, :category, :string
  end
end
