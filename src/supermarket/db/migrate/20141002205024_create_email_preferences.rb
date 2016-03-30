class CreateEmailPreferences < ActiveRecord::Migration
  def change
    create_table :email_preferences do |t|
      t.references :user, null: false
      t.references :system_email, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :email_preferences, :token, unique: true
    add_index :email_preferences, [:user_id, :system_email_id], unique: true
  end
end
