class CookbookDeprecations < ActiveRecord::Migration[4.2]
  def change
    change_table :cookbooks do |t|
      t.integer :replacement_id, index: true
    end
  end
end
