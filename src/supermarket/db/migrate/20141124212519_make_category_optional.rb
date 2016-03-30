class MakeCategoryOptional < ActiveRecord::Migration
  def up
    change_column :cookbooks, :category_id, :integer, null: true
  end

  def down
    change_column :cookbooks, :category_id, :integer, null: false
  end
end
