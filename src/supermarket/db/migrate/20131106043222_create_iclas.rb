class CreateIclas < ActiveRecord::Migration[4.2]
  def change
    create_table :iclas do |t|
      t.string :version, index: true, unique: true
      t.text :head
      t.text :body
      t.timestamps
    end
  end
end
