class AddIclaIdToIclaSignatures < ActiveRecord::Migration[4.2]
  def change
    add_column :icla_signatures, :icla_id, :integer
    add_index :icla_signatures, :icla_id
  end
end
