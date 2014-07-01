if ENV['SENTRY_URL'].present? && !Rails.env.test?
  require 'raven'
  require 'raven/sidekiq'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_URL']
  end
end
