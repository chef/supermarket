class AddProfileAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :jira_username, :string
    add_column :users, :irc_nickname, :string
  end
end
