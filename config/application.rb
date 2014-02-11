require File.expand_path('../boot', __FILE__)

require "rails"

%w(
    active_record
    action_controller
    action_mailer
    sprockets
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Supermarket
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Autoload everything in lib
    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/**/*"]

    # Autoload everything in app
    config.autoload_paths += Dir["#{config.root}/app", "#{config.root}/app/**/*"]

    # Include vendor fonts in the asset pipeline
    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")

    # Ensure fonts are precompiled during asset compilation
    config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)

    # Use a custom exception handling application
    config.exceptions_app = Proc.new do |env|
      ExceptionsController.action(:show).call(env)
    end

    # Define the status codes for rescuing our custom exceptions
    config.action_dispatch.rescue_responses.merge!(
      'Supermarket::Authorization::NoAuthorizerError'  => :not_implemented,
      'Supermarket::Authorization::NotAuthorizedError' => :unauthorized,
    )

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Skip locale validation.
    # Note: if the time comes to support locales, this will want to be set to
    # true.
    config.i18n.enforce_available_locales = false

    # Allow magiconf to work with application configuration
    Magiconf.setup!

    # Set default URL for ActionMailer
    config.action_mailer.default_url_options = {
      host: Supermarket::Config.host,
      port: Supermarket::Config.port
    }
  end
end
