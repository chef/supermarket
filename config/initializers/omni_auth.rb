Rails.application.config.middleware.use(OmniAuth::Builder) do
  omni_auth = Supermarket::Config.omni_auth

  provider :twitter,
    omni_auth['twitter']['key'],
    omni_auth['twitter']['secret'],
    omni_auth['twitter']['options'] || {}

  provider :github,
    omni_auth['github']['key'],
    omni_auth['github']['secret'],
    omni_auth['twitter']['options'] || {}
end

OmniAuth.config.logger = Rails.logger
