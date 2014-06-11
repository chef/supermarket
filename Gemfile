source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '~> 4.1.1'

gem 'magiconf'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-chef-oauth2', git: 'https://github.com/opscode/omniauth-chef-oauth2.git'
gem 'pg'
gem 'redcarpet' # markdown parsing
gem 'unicorn'
gem 'unicorn-rails'
gem 'foreman'
gem 'pundit'
gem 'dotenv'
gem 'coveralls', require: false
gem 'octokit', github: 'octokit/octokit.rb', require: false
gem 'sidekiq'
gem 'sidetiq', github: 'tobiassvn/sidetiq', ref: '4f7d7da'
gem 'premailer-rails', group: [:development, :production]
gem 'nokogiri'
gem 'jbuilder'
gem 'pg_search'
gem 'paperclip'
gem 'virtus', require: false
gem 'kaminari'
gem 'validate_url'
gem 'chef', require: false
gem 'mixlib-authentication'
gem 'aws-sdk'
gem 'newrelic_rpm'
gem 'semverse'
gem 'sitemap_generator'

gem 'sentry-raven', '~> 0.8.0', require: false
gem 'statsd-ruby', require: 'statsd'
gem 'analytics-ruby', require: false

gem 'sass-rails',   '~> 4.0.1'
gem 'compass-rails'
gem 'uglifier',     '~> 2.2'

gem 'chef-legacy', github: 'gofullstack/chef-legacy', ref: 'v1.0.0'

group :doc do
  gem 'yard', require: false
end

group :development do
  gem 'license_finder'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'factory_girl'
  gem 'poltergeist'
  gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers', ref: '380d18f0621c66a79445ebc6dcc0048fcc969911'
  gem 'database_cleaner'
  gem 'vcr', require: false
  gem 'webmock', require: false
end

group :development, :test do
  gem 'rubocop'
  gem 'mail_view'
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'byebug'
  gem 'launchy'
  gem 'and_feathers', '>= 1.0.0.pre', require: false
  gem 'and_feathers-gzipped_tarball', '>= 1.0.0.pre', require: false
end
