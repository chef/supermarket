class AddReadmeToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    change_table :cookbook_versions do |t|
      t.text :readme
      t.string :readme_extension
    end
  end
end
