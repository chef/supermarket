class AddPartnerStatus < ActiveRecord::Migration
  def change
    add_column :cookbooks, :partner_status, :boolean
    add_column :tools, :partner_status, :boolean
  end
end
