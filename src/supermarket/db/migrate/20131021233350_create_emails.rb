class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :user, index: true
      t.string     :email, index: true, unique: true

      # Emails must be confirmed
      t.string     :confirmation_token
      t.datetime   :confirmed_at
    end
  end
end
