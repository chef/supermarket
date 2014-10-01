class CreateUnsubscribeRequests < ActiveRecord::Migration
  def change
    create_table :unsubscribe_requests do |t|
      t.references :user, null: false
      t.string :token, null: false
      t.string :email_preference_name, null: false
      t.timestamps
    end

    add_index :unsubscribe_requests, :token, unique: true
  end
end
