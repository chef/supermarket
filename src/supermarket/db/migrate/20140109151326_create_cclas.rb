class CreateCclas < ActiveRecord::Migration[4.2]
  def change
    create_table :cclas do |t|
      t.string :version, index: true, unique: true
      t.text :head
      t.text :body
      t.timestamps
    end
  end
end
