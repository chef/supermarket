class AddAdoptionToCookbook < ActiveRecord::Migration
  def change
    add_column :cookbooks, :up_for_adoption, :boolean
  end
end
