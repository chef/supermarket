class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :prefix
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :phone
      t.integer :primary_email_id

      t.timestamps
    end
  end
end
