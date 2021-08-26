class RemoveIrcColumnsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :irc_nickname
  end
end
