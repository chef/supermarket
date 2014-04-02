Rails.application.config.middleware.use(OmniAuth::Builder) do
  provider(
    :github,
    Supermarket::Config.omniauth['github']['key'],
    Supermarket::Config.omniauth['github']['secret']
  )

  provider(
    :chef_oauth2,
    Supermarket::Config.omniauth['chef_oauth2']['app_id'],
    Supermarket::Config.omniauth['chef_oauth2']['secret']
  )
end

# Use the Rails logger
OmniAuth.config.logger = Rails.logger
