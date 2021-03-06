class RemoveEmailNotificationsFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :email_notifications
  end

  def down
    add_column :users, :email_notifications, :boolean, default: true
  end
end
