class DropCclaIclaRelatedTables < ActiveRecord::Migration[6.1]
  def change
    drop_table  :iclas, if_exists: true
    drop_table  :icla_signatures, if_exists: true
    drop_table  :cla_reports, if_exists: true
    drop_table  :cclas, if_exists: true
    drop_table  :ccla_signatures,if_exists: true
  end
end
