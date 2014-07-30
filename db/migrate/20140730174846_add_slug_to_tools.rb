class AddSlugToTools < ActiveRecord::Migration
  def up
    add_column :tools, :slug, :string
    add_index :tools, :slug, unique: true

    Tool.all.each do |tool|
      tool.update_attribute(:slug, "#{tool.id}-#{tool.name.parameterize}")
    end
  end

  def down
    remove_column :tools, :slug
  end
end
