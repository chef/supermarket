source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '~> 4.0.3'

gem 'magiconf'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'pg'
gem 'redcarpet' # markdown parsing
gem 'unicorn'
gem 'unicorn-rails'
gem 'foreman'
gem 'pundit'
gem 'devise'
gem 'dotenv-rails'
gem 'coveralls', require: false
gem 'octokit', github: 'octokit/octokit.rb', require: false
gem 'sidekiq'
gem 'premailer-rails', group: [:development, :production]
gem 'jbuilder'
gem 'pg_search'
gem 'paperclip'
gem 'virtus', require: false
gem 'kaminari'
gem 'chef', require: ['chef/version_constraint', 'chef/exceptions']

gem 'sentry-raven', github: 'getsentry/raven-ruby'
gem 'statsd-ruby', require: 'statsd'
gem 'analytics-ruby', require: false

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
end

group :test do
  gem 'capybara'
  gem 'factory_girl'
  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'nokogiri', require: false
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
