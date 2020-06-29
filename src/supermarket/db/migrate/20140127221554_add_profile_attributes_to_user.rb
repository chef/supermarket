class AddProfileAttributesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :jira_username, :string
    add_column :users, :irc_nickname, :string
  end
end
