class AddPrivateToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :privacy, :boolean
  end
end
