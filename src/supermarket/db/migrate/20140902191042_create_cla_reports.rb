class CreateClaReports < ActiveRecord::Migration
  def change
    create_table :cla_reports do |t|
      t.integer :first_ccla_id
      t.integer :last_ccla_id
      t.integer :first_icla_id
      t.integer :last_icla_id
      t.attachment :csv

      t.timestamps
    end
  end
end
