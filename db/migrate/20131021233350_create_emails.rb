class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :user, index: true
      t.string     :email, index: true, unique: true

      # Specify a primary email address
      t.boolean    :primary, default: false

      # Emails must be confirmed
      t.string     :confirmation_code
      t.datetime   :confirmed_at
    end
  end
end
