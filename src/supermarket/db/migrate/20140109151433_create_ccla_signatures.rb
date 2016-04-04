class CreateCclaSignatures < ActiveRecord::Migration
  def change
    create_table :ccla_signatures do |t|
      t.references :user, index: true
      t.references :organization, index: true
      t.references :ccla, index: true

      t.datetime :signed_at

      t.string :prefix
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :email
      t.string :phone
      t.string :company
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end
  end
end
