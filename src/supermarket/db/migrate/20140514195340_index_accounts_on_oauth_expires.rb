class IndexAccountsOnOauthExpires < ActiveRecord::Migration
  def change
    add_index :accounts, :oauth_expires
  end
end
