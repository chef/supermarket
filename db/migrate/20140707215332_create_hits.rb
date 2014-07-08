class CreateHits < ActiveRecord::Migration
  def change
    create_table :hits do |t|
      t.integer :universe, null: false, default: 0
      t.timestamps
    end
  end
end
