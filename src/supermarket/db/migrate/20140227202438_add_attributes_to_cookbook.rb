class AddAttributesToCookbook < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbooks, :category, :string
    add_column :cookbooks, :external_url, :string
    add_column :cookbooks, :deprecated, :boolean, default: false
  end
end
