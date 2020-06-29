class AddSlugToCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :slug, :string
    add_index :categories, :slug
  end
end
