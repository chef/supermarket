class DropCclaIclaRelatedTables < ActiveRecord::Migration[6.1]
  def change
    drop_table  :iclas
    drop_table  :icla_signatures
    drop_table  :cla_reports
    drop_table  :cclas
    drop_table  :ccla_signatures
  end
end
