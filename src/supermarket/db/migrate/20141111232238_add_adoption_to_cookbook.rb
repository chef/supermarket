class AddAdoptionToCookbook < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :up_for_adoption, :boolean
    add_column :tools, :up_for_adoption, :boolean
  end
end
