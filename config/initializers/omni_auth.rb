Rails.application.config.middleware.use(OmniAuth::Builder) do
  Supermarket::Config.omni_auth.each do |key, hash|
    provider key.to_sym,
      hash['key'],
      hash['secret'],
      hash['options'] || {}
  end
end

# Use the Rails logger
OmniAuth.config.logger = Rails.logger

# Set top-level OmniAuth failures to fail in the application controller
unless Rails.env.development?
  OmniAuth.config.on_failure = Proc.new do |env|
    ApplicationController.action(:omniauth_error).call(env)
  end
end
