class AddCategoryIdToCookbooks < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :category_id, :integer
    remove_column :cookbooks, :category, :string
  end
end
