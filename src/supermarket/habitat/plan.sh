pkg_name=supermarket
pkg_origin=chefops
pkg_version="$(cat $PLAN_CONTEXT/../../../VERSION)"
pkg_maintainer="Chef Operations <ops@chef.io>"
pkg_license=('Apache-2.0')
pkg_scaffolding=jtimberman/scaffolding-ruby

pkg_deps=(
  core/curl
  core/file
  core/jq-static
  core/bash
)

pkg_build_deps=(
  core/git
)

pkg_exports=(
  [protocol]="app.protocol"
  [fqdn]="app.fqdn"
  [port]="app.port"
  [listen_port]="web.listen_port"
)

pkg_exposes=(listen_port)

pkg_binds_optional=(
  [redis]="port"
)

do_prepare() {
  do_default_prepare
  mkdir -p .bundle
  echo "BUNDLE_BUILD__RUBY-FILEMAGIC: \"--with-magic-dir=$(pkg_path_for core/file)\"" >> $PLAN_CONTEXT/../.bundle/config
}

do_install() {
  do_default_install
  # feed scaffolding managed env vars to dotenv until dotenv is removed
  ln -nsf "${pkg_svc_config_path}/app_env.sh" "${pkg_prefix}/app/.env.production"
  # link to the hab-rendered unicorn config
  ln -nsf "${pkg_svc_config_path}/unicorn.rb" "${pkg_prefix}/app/config/unicorn/production.rb"
  # link to the hab-rendered sidekiq config
  ln -nsf "${pkg_svc_config_path}/sidekiq.yml" "${pkg_prefix}/app/config/sidekiq.yml"
}

declare -A scaffolding_process_bins
scaffolding_process_bins[dbcreate]="bundle exec rake db:create db:schema:load db:seed"
scaffolding_process_bins[release]="bundle exec rake db:migrate db:seed"

declare -A scaffolding_env
scaffolding_env[FQDN]={{cfg.app.fqdn}}
scaffolding_env[PORT]={{cfg.app.port}}
scaffolding_env[PROTOCOL]={{cfg.app.protocol}}
scaffolding_env[LOG_LEVEL]={{cfg.app.log_level}}
scaffolding_env[SECRET_KEY_BASE]={{cfg.app.secret_key_base}}
scaffolding_env[CHEF_OAUTH2_APP_ID]={{cfg.app.chef_oauth2_app_id}}
scaffolding_env[CHEF_OAUTH2_SECRET]={{cfg.app.chef_oauth2_secret}}
scaffolding_env[CHEF_OAUTH2_URL]={{cfg.app.chef_oauth2_url}}
scaffolding_env[CHEF_OAUTH2_VERIFY_SSL]={{cfg.app.chef_oauth2_verify_ssl}}
scaffolding_env[CHEF_IDENTITY_URL]={{cfg.app.chef_identity_url}}
scaffolding_env[CHEF_PROFILE_URL]={{cfg.app.chef_profile_url}}
scaffolding_env[CHEF_SIGN_UP_URL]={{cfg.app.chef_sign_up_url}}
scaffolding_env[CHEF_DOMAIN]={{cfg.app.chef_domain}}
scaffolding_env[CHEF_BLOG_URL]={{cfg.app.chef_blog_url}}
scaffolding_env[CHEF_DOCS_URL]={{cfg.app.chef_docs_url}}
scaffolding_env[CHEF_DOWNLOADS_URL]={{cfg.app.chef_downloads_url}}
scaffolding_env[CHEF_WWW_URL]={{cfg.app.chef_www_url}}
scaffolding_env[LEARN_CHEF_URL]={{cfg.app.learn_chef_url}}
scaffolding_env[FEATURES]={{cfg.app.features}}
scaffolding_env[ENFORCE_PRIVACY]={{cfg.app.enforce_privacy}}
scaffolding_env[AIR_GAPPED]={{cfg.app.air_gapped}}
scaffolding_env[FIERI_URL]={{cfg.app.fieri_url}}
scaffolding_env[FIERI_SUPERMARKET_ENDPOINT]={{cfg.app.fieri_supermarket_endpoint}}
scaffolding_env[FIERI_KEY]={{cfg.app.fieri_key}}
scaffolding_env[FIERI_FOODCRITIC_TAGS]={{cfg.app.fieri_foodcritic_tags}}
scaffolding_env[FIERI_FOODCRITIC_FAIL_TAGS]={{cfg.app.fieri_foodcritic_fail_tags}}
scaffolding_env[GOOGLE_ANALYTICS_ID]={{cfg.app.google_analytics_id}}
scaffolding_env[SENTRY_URL]={{cfg.app.sentry_url}}
scaffolding_env[NEW_RELIC_AGENT_ENABLED]={{cfg.app.new_relic_agent_enabled}}
scaffolding_env[NEW_RELIC_APP_NAME]={{cfg.app.new_relic_app_name}}
scaffolding_env[NEW_RELIC_LICENSE_KEY]={{cfg.app.new_relic_license_key}}
scaffolding_env[GITHUB_ACCESS_TOKEN]={{cfg.app.github_access_token}}
scaffolding_env[GITHUB_KEY]={{cfg.app.github_key}}
scaffolding_env[GITHUB_SECRET]={{cfg.app.github_secret}}
scaffolding_env[ROBOTS_ALLOW]={{cfg.app.robots_allow}}
scaffolding_env[ROBOTS_DISALLOW]={{cfg.app.robots_disallow}}
scaffolding_env[S3_BUCKET]={{cfg.app.s3_bucket}}
scaffolding_env[S3_ACCESS_KEY_ID]={{cfg.app.s3_access_key_id}}
scaffolding_env[S3_SECRET_ACCESS_KEY]={{cfg.app.s3_secret_access_key}}
scaffolding_env[S3_REGION]={{cfg.app.s3_region}}
scaffolding_env[S3_PATH]={{cfg.app.s3_path}}
scaffolding_env[S3_PRIVATE_OBJECTS]={{cfg.app.s3_private_objects}}
scaffolding_env[CDN_URL]={{cfg.app.cdn_url}}
scaffolding_env[FROM_EMAIL]={{cfg.app.from_email}}
scaffolding_env[SMTP_ADDRESS]={{cfg.app.smtp_address}}
scaffolding_env[SMTP_PASSWORD]={{cfg.app.smtp_password}}
scaffolding_env[SMTP_PORT]={{cfg.app.smtp_port}}
scaffolding_env[SMTP_USER_NAME]={{cfg.app.smtp_user_name}}
scaffolding_env[STATSD_URL]={{cfg.app.statsd_url}}
scaffolding_env[STATSD_PORT]={{cfg.app.statsd_port}}

declare redis
redis="redis://{{#if cfg.redis.password}}:{{cfg.redis.password}}@{{/if}}"
redis="${redis}{{#if bind.redis}}{{bind.redis.first.sys.ip}}{{else}}{{#if cfg.redis.host}}{{cfg.redis.host}}{{else}}redis.host.not.set{{/if}}{{/if}}"
redis="${redis}:{{#if bind.redis}}{{bind.redis.first.cfg.port}}{{else}}{{#if cfg.redis.port}}{{cfg.redis.port}}{{else}}6379{{/if}}{{/if}}"
redis="${redis}/{{cfg.redis.db}}"
scaffolding_env[REDIS_URL]="${redis}"
