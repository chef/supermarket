class AddEmailPreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_preferences, :integer
  end
end
