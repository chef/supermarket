class AddReadmeToCookbookVersion < ActiveRecord::Migration
  def change
    change_table :cookbook_versions do |t|
      t.text :readme
      t.string :readme_extension
    end
  end
end
