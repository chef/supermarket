class AddSlackColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :slack_username, :string
  end
end
