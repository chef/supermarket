class AddPartnerStatus < ActiveRecord::Migration
  def change
    add_column :cookbooks, :partner, :boolean
    add_column :tools, :partner, :boolean
  end
end
