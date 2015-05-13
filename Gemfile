source 'https://rubygems.org'

# Ruby version isn't specified here anymore, as it's pinned in Omnibus
# https://github.com/chef/omnibus-supermarket/blob/master/config/projects/supermarket.rb

gem 'rails', '~> 4.1.5'

gem 'omniauth'
gem 'omniauth-chef-oauth2'
gem 'omniauth-github'

gem 'pg'
gem 'redcarpet' # markdown parsing
gem 'unicorn'
gem 'unicorn-rails'
gem 'foreman'
gem 'pundit'
gem 'dotenv'
gem 'coveralls', require: false
gem 'octokit', git: 'https://github.com/octokit/octokit.rb.git', require: false
gem 'sidekiq'

# Pin sprockets to ensure we get the latest security patches. Not pinning this
# meant that the gem that depended on sprockets was pulling in an old
# (vulnerable) version.
gem 'sprockets', '~> 2.11.3'

# Use the version on GitHub because the version published on RubyGems has
# compatibility problems with Sidekiq 3.0.
gem 'sidetiq', git: 'https://github.com/tobiassvn/sidetiq.git', ref: '4f7d7da'

gem 'premailer-rails', group: [:development, :production]
gem 'nokogiri'
gem 'jbuilder'
gem 'pg_search', '~> 0.7.6'
gem 'paperclip'

# Pin virtus to a version before the handling of nil in collection coercion was
# fixed.
gem 'virtus', '1.0.2', require: false

gem 'kaminari'
gem 'validate_url'
gem 'chef', '~> 12.0', require: false
gem 'chef-zero', '~> 4.2.1', require: false
gem 'mixlib-authentication'
gem 'aws-sdk'
gem 'newrelic_rpm'
gem 'semverse'
gem 'sitemap_generator'
gem 'redis-rails'
gem 'yajl-ruby'
gem 'utf8-cleaner'
gem 'rinku', require: 'rails_rinku'
gem 'html_truncator'
gem 'rollout'
gem 'statsd-ruby'
gem 'sentry-raven', '~> 0.12.0', require: false
gem 'sass-rails',   '~> 4.0.4'
gem 'compass-rails'
gem 'uglifier',     '~> 2.2'

group :doc do
  gem 'yard', require: false
end

group :development do
  gem 'license_finder'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'faker'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'factory_girl'
  gem 'poltergeist'

  # To prevent the validates_uniqueness matcher from raising a chef version
  # constraint error this pins shoulda-matchers at a commit where setting
  # default values for scopes was reverted
  gem 'shoulda-matchers',
      git: 'https://github.com/thoughtbot/shoulda-matchers.git',
      ref: '380d18f0621c66a79445ebc6dcc0048fcc969911'

  gem 'database_cleaner'
  gem 'vcr', require: false
  gem 'webmock', require: false
end

group :development, :test do
  gem 'rubocop', '~> 0.26.0'
  gem 'mail_view'
  gem 'quiet_assets'
  gem 'rspec-rails', '~> 3.2.0'
  gem 'byebug'
  gem 'launchy'

  # Pinned to be greater than or equal to 1.0.0.pre because the gems were prior
  # to 1.0.0 release when added
  gem 'and_feathers', '>= 1.0.0.pre', require: false
  gem 'and_feathers-gzipped_tarball', '>= 1.0.0.pre', require: false
end
