class CreateSystemEmails < ActiveRecord::Migration
  def change
    create_table :system_emails do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
