class AddBadgesToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :badges_mask, :integer, default: 0, null: false
  end
end
