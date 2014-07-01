Rails.application.config.middleware.use(OmniAuth::Builder) do
  provider(
    :github,
    ENV['GITHUB_KEY'],
    ENV['GITHUB_SECRET']
  )

  provider(
    :chef_oauth2,
    ENV['CHEF_OAUTH2_APP_ID'],
    ENV['CHEF_OAUTH2_SECRET']
  )
end

# Use the Rails logger
OmniAuth.config.logger = Rails.logger
