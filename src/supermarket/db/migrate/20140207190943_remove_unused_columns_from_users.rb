class RemoveUnusedColumnsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :prefix, :string
    remove_column :users, :middle_name, :string
    remove_column :users, :suffix, :string
    remove_column :users, :phone, :string
    remove_column :users, :primary_email_id, :integer
    remove_column :users, :username, :string
  end
end
