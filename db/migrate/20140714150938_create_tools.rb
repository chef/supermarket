class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.references :user, index: true

      t.string :name
      t.string :type
      t.text :description
      t.string :source_url
      t.text :instructions

      t.timestamps
    end
  end
end
