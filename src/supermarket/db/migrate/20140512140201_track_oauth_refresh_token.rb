class TrackOauthRefreshToken < ActiveRecord::Migration[4.2]
  def change
    change_table :accounts do |t|
      t.string :oauth_refresh_token
    end
  end
end
