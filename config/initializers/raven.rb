require 'raven'

Raven.configure do |config|
  config.dsn = Supermarket::Config.sentry_url
end
