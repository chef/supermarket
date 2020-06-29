class ChangeCategoryIdOnCookbooksToNotNullable < ActiveRecord::Migration[4.2]
  def change
    change_column :cookbooks, :category_id, :integer, null: false
  end
end
