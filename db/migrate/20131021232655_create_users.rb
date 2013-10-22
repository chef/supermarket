class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :prefix
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix

      t.string :phone

      # Store when the user signed the CLA
      t.datetime   :icla_signed_at

      t.timestamps
    end
  end
end
