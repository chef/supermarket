# OmniAuth configuration

# Set the full_host for OmniAuth
#
# If this is not set correctly, OmniAuth may not generate redirect_uri
# parameters in requests correctly.
#
# See http://www.kbedell.com/2011/03/08/overriding-omniauth-callback-url-for-twitter-or-facebook-oath-processing/
OmniAuth.config.full_host = "#{ENV['PROTOCOL']}://" \
  "#{ENV['HOST']}" \
  "#{[80, 443].include?(ENV['PORT'].to_i) ? '' : ':' + ENV['PORT']}"

# Configure middleware used by OmniAuth
Rails.application.config.middleware.use(OmniAuth::Builder) do
  provider(
    :github,
    ENV['GITHUB_KEY'],
    ENV['GITHUB_SECRET']
  )

  # Use an alternate URL for the Chef OAuth2 service if one is provided
  client_options = {
    ssl: {
      verify: ENV['CHEF_OAUTH2_VERIFY_SSL'].present? &&
              ENV['CHEF_OAUTH2_VERIFY_SSL'] != 'false'
    }
  }

  if ENV['CHEF_OAUTH2_URL'].present?
    client_options[:site] = ENV['CHEF_OAUTH2_URL']
  end

  provider(
    :chef_oauth2,
    ENV['CHEF_OAUTH2_APP_ID'],
    ENV['CHEF_OAUTH2_SECRET'],
    client_options: client_options
  )
end

# Use the Rails logger
OmniAuth.config.logger = Rails.logger
