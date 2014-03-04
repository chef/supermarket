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
