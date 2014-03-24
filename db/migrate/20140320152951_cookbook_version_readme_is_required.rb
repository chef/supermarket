class CookbookVersionReadmeIsRequired < ActiveRecord::Migration
  def change
    change_column :cookbook_versions, :readme, :text, null: false, default: ''
    change_column :cookbook_versions, :readme_extension, :string, null: false, default: ''
  end
end
