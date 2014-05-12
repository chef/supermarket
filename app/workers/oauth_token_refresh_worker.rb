class OauthTokenRefreshWorker
  include Sidekiq::Worker

  #
  # Refresh the OAuth token of the given account
  #
  # @param [Integer] account_id the ID for the Account
  #
  def perform(account_id)
    account = Account.find(account_id)

    strategy = OmniAuth::Strategies::ChefOAuth2.new(
      Rails.application,
      client_id: ENV['CHEF_OAUTH2_APP_ID'],
      client_secret: ENV['CHEF_OAUTH2_SECRET']
    )

    access_token = OAuth2::AccessToken.new(
      strategy.client,
      account.oauth_token,
      refresh_token: account.oauth_refresh_token,
      expires_at: account.oauth_expires
    )

    refreshed_token = access_token.refresh!

    account.update_attributes!(
      oauth_token: refreshed_token.token,
      oauth_expires: Time.at(refreshed_token.expires_at),
      oauth_refresh_token: refreshed_token.refresh_token
    )
  rescue ActiveRecord::RecordNotFound, OAuth2::Error => e
    logger.error(e.message) unless Rails.env.test?
  end
end
