class RemoveEmails < ActiveRecord::Migration[4.2]
  def change
    drop_table :emails
  end
end
