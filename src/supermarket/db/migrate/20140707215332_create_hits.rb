class CreateHits < ActiveRecord::Migration[4.2]
  def change
    create_table :hits do |t|
      t.string :label, null: false
      t.integer :total, null: false, default: 0
    end

    add_index :hits, :label, unique: true
  end
end
