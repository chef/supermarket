class AddBadgesToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :badges_mask, :integer
  end
end
