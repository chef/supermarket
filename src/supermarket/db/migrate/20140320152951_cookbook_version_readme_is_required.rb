class CookbookVersionReadmeIsRequired < ActiveRecord::Migration[4.2]
  def change
    change_column :cookbook_versions, :readme, :text, null: false, default: ''
    change_column :cookbook_versions, :readme_extension, :string, null: false, default: ''
  end
end
