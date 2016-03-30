class AdjustCookbookUrls < ActiveRecord::Migration
  def change
    rename_column :cookbooks, :external_url, :source_url
    add_column :cookbooks, :issues_url, :string
  end
end
