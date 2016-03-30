class ChangeCategoryIdOnCookbooksToNotNullable < ActiveRecord::Migration
  def change
    change_column :cookbooks, :category_id, :integer, null: false
  end
end
