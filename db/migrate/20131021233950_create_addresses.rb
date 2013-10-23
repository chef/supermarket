class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :user, index: true
      t.string     :address_line_1
      t.string     :address_line_2
      t.string     :city
      t.string     :state
      t.string     :zip
      t.string     :country
    end
  end
end
