class ReIndexDb < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    execute "REINDEX DATABASE #{ActiveRecord::Base.connection.current_database};" 
  end

  def down
      raise ActiveRecord::IrreversibleMigration
  end
end
