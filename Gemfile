source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '~> 4.1.5'

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
gem 'chef', '~> 11.10.4', require: false
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

gem 'sentry-raven', '~> 0.8.0', require: false
gem 'analytics-ruby', '~> 1.0.0', require: false

gem 'sass-rails',   '~> 4.0.1'
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
  gem 'rubocop', '>= 0.23.0'
  gem 'mail_view'
  gem 'quiet_assets'
  gem 'rspec-rails', '~> 3.0.2'
  gem 'byebug'
  gem 'launchy'
  gem 'and_feathers', '>= 1.0.0.pre', require: false
  gem 'and_feathers-gzipped_tarball', '>= 1.0.0.pre', require: false
end
