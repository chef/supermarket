if ENV['SENTRY_URL'].present? && !Rails.env.test?
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_URL']
  end
end
