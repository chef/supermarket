if Supermarket::Config.sentry_url.present? && !Rails.env.test?
  require 'raven'

  Raven.configure do |config|
    config.dsn = Supermarket::Config.sentry_url
  end
end
