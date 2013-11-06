class AddIclaIdToIclaSignatures < ActiveRecord::Migration
  def change
    add_column :icla_signatures, :icla_id, :integer
  end
end
