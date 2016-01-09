class AddBadgesToCookbooksAndTools < ActiveRecord::Migration
  def change
    add_column :cookbooks, :badges_mask, :integer
    add_column :tools, :badges_mask, :integer
  end
end
