pkg_name=supermarket-app
pkg_origin=robbkidd
pkg_version="$(cat $PLAN_CONTEXT/../../../VERSION)"
pkg_maintainer="Supermarket Team <supermarket@chef.io>"
pkg_license=('Apache-2.0')
pkg_scaffolding=robbkidd/scaffolding-ruby

pkg_deps=(
  core/file
)

pkg_build_deps=(
  core/git
)

do_prepare() {
  do_default_prepare
  mkdir -p .bundle
  echo "BUNDLE_BUILD__RUBY-FILEMAGIC: \"--with-magic-dir=$(pkg_path_for core/file)\"" >> $PLAN_CONTEXT/../.bundle/config
}

declare -A scaffolding_env
scaffolding_env[FQDN]={{cfg.fqdn}}
scaffolding_env[PORT]={{cfg.port}}
scaffolding_env[PROTOCOL]={{cfg.protocol}}
scaffolding_env[LOG_LEVEL]={{cfg.log_level}}
scaffolding_env[SECRET_KEY_BASE]={{cfg.secret_key_base}}
scaffolding_env[CHEF_OAUTH2_APP_ID]={{cfg.chef_oauth2_app_id}}
scaffolding_env[CHEF_OAUTH2_SECRET]={{cfg.chef_oauth2_secret}}
scaffolding_env[CHEF_OAUTH2_URL]={{cfg.chef_oauth2_url}}
scaffolding_env[CHEF_OAUTH2_VERIFY_SSL]={{cfg.chef_oauth2_verify_ssl}}
scaffolding_env[CHEF_IDENTITY_URL]={{cfg.chef_identity_url}}
scaffolding_env[CHEF_PROFILE_URL]={{cfg.chef_profile_url}}
scaffolding_env[CHEF_SIGN_UP_URL]={{cfg.chef_sign_up_url}}
scaffolding_env[CHEF_DOMAIN]={{cfg.chef_domain}}
scaffolding_env[CHEF_BLOG_URL]={{cfg.chef_blog_url}}
scaffolding_env[CHEF_DOCS_URL]={{cfg.chef_docs_url}}
scaffolding_env[CHEF_DOWNLOADS_URL]={{cfg.chef_downloads_url}}
scaffolding_env[CHEF_WWW_URL]={{cfg.chef_www_url}}
scaffolding_env[LEARN_CHEF_URL]={{cfg.learn_chef_url}}
scaffolding_env[FEATURES]={{cfg.features}}
scaffolding_env[ENFORCE_PRIVACY]={{cfg.enforce_privacy}}
scaffolding_env[AIR_GAPPED]={{cfg.air_gapped}}
scaffolding_env[FIERI_URL]={{cfg.fieri_url}}
scaffolding_env[FIERI_SUPERMARKET_ENDPOINT]={{cfg.fieri_supermarket_endpoint}}
scaffolding_env[FIERI_KEY]={{cfg.fieri_key}}
scaffolding_env[FIERI_FOODCRITIC_TAGS]={{cfg.fieri_foodcritic_tags}}
scaffolding_env[FIERI_FOODCRITIC_FAIL_TAGS]={{cfg.fieri_foodcritic_fail_tags}}
scaffolding_env[GOOGLE_ANALYTICS_ID]={{cfg.google_analytics_id}}
scaffolding_env[SENTRY_URL]={{cfg.sentry_url}}
scaffolding_env[NEW_RELIC_AGENT_ENABLED]={{cfg.new_relic_agent_enabled}}
scaffolding_env[NEW_RELIC_APP_NAME]={{cfg.new_relic_app_name}}
scaffolding_env[NEW_RELIC_LICENSE_KEY]={{cfg.new_relic_license_key}}
scaffolding_env[GITHUB_ACCESS_TOKEN]={{cfg.github_access_token}}
scaffolding_env[GITHUB_KEY]={{cfg.github_key}}
scaffolding_env[GITHUB_SECRET]={{cfg.github_secret}}
scaffolding_env[ROBOTS_ALLOW]={{cfg.robots_allow}}
scaffolding_env[ROBOTS_DISALLOW]={{cfg.robots_disallow}}
scaffolding_env[S3_BUCKET]={{cfg.s3_bucket}}
scaffolding_env[S3_ACCESS_KEY_ID]={{cfg.s3_access_key_id}}
scaffolding_env[S3_SECRET_ACCESS_KEY]={{cfg.s3_secret_access_key}}
scaffolding_env[S3_REGION]={{cfg.s3_region}}
scaffolding_env[S3_PATH]={{cfg.s3_path}}
scaffolding_env[S3_PRIVATE_OBJECTS]={{cfg.s3_private_objects}}
scaffolding_env[CDN_URL]={{cfg.cdn_url}}
scaffolding_env[FROM_EMAIL]={{cfg.from_email}}
scaffolding_env[SMTP_ADDRESS]={{cfg.smtp_address}}
scaffolding_env[SMTP_PASSWORD]={{cfg.smtp_password}}
scaffolding_env[SMTP_PORT]={{cfg.smtp_port}}
scaffolding_env[SMTP_USER_NAME]={{cfg.smtp_user_name}}
scaffolding_env[STATSD_URL]={{cfg.statsd_url}}
scaffolding_env[STATSD_PORT]={{cfg.statsd_port}}
