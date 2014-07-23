class AddFeaturedToCookbooks < ActiveRecord::Migration
  def change
    add_column :cookbooks, :featured, :boolean, default: false
  end
end
