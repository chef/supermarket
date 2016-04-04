class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :user, index: true
      t.string     :uid,  index: true
      t.string     :username, index: true
      t.string     :oauth_token
      t.string     :oauth_secret
      t.datetime   :oauth_expires
    end
  end
end
