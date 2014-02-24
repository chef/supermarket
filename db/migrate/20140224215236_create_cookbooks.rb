class CreateCookbooks < ActiveRecord::Migration
  def change
    create_table :cookbooks do |t|
      t.string :name, null: false
      t.string :maintainer, null: false
      t.text :description

      t.timestamps
    end
  end
end
