class CreateCookbooks < ActiveRecord::Migration[4.2]
  def change
    create_table :cookbooks do |t|
      t.string :name, null: false
      t.string :maintainer, null: false
      t.text :description

      t.timestamps
    end
  end
end
