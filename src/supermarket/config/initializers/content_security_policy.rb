# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src :self, :https, :data, "http://fonts.gstatic.com"
  policy.img_src :self, :https, :data, "www.googletagmanager.com"
  policy.connect_src :self, :https, "wss://ws.hotjar.com"
  policy.script_src :self, :blob, :https, "https://www.googletagmanager.com",
                                    "https://www.google-analytics.com",
                                    "http://cdn.segment.com"
  policy.object_src :none
  # Need to keep the unsafe_inline for style-src directive as
  # there is an inline css embedded in the application.js file.
  # Without unsafe_inline it will block the style tag.
  # Style tags are not considered that much unsafe as externally injected script through xss attack.
  policy.style_src :self, :unsafe_inline, :https, "http://fonts.googleapis.com"

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w{ script-src }

# Generate session nonces for permitted importmap and inline scripts
# Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true