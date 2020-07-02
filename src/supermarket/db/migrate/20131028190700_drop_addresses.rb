class DropAddresses < ActiveRecord::Migration[4.2]
  def change
    drop_table :addresses
  end
end
