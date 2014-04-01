class AddEmailNotificationsBooleanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_notifications, :boolean, default: true
  end
end
