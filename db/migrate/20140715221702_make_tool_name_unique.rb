class MakeToolNameUnique < ActiveRecord::Migration
  def up
    add_column :tools, :lowercase_name, :string
    add_index :tools, :lowercase_name, unique: true
  end

  def down
    remove_index :tools, :lowercase_name
    remove_column :tools, :lowercase_name
  end
end
