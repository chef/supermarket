if Supermarket::Config.sentry_url.present? && !Rails.env.test?
  require 'raven'
  require 'raven/sidekiq'

  Raven.configure do |config|
    config.dsn = Supermarket::Config.sentry_url
  end
end
