class AddBadgesToCookbooks < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :badges_mask, :integer, default: 0, null: false
  end
end
