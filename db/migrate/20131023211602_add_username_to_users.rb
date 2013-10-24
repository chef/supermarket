class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, index: true, unique: true
  end
end
