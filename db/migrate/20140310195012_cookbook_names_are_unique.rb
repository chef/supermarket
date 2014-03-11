class CookbookNamesAreUnique < ActiveRecord::Migration
  def up
    change_table :cookbooks do |t|
      t.string :lowercase_name
    end

    Cookbook.reset_column_information

    Cookbook.update_all('lowercase_name = LOWER(name)')

    add_index :cookbooks, :lowercase_name, unique: true
  end
end
