class AddAdoptionToCookbook < ActiveRecord::Migration
  def change
    add_column :cookbooks, :up_for_adoption, :boolean
    add_column :tools, :up_for_adoption, :boolean
  end
end
