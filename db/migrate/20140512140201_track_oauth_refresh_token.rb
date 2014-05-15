class TrackOauthRefreshToken < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.string :oauth_refresh_token
    end
  end
end
