if Supermarket::Config.sentry_url.present?
  require 'raven'

  Raven.configure do |config|
    config.dsn = Supermarket::Config.sentry_url
  end
end
