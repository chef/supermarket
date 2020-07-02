class AddFeaturedToCookbooks < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :featured, :boolean, default: false
  end
end
