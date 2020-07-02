class IndexAccountsOnOauthExpires < ActiveRecord::Migration[4.2]
  def change
    add_index :accounts, :oauth_expires
  end
end
