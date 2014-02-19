source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '~> 4.0.2'

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
gem 'sentry-raven', github: 'getsentry/raven-ruby'
gem 'statsd-ruby', require: 'statsd'
gem 'octokit', github: 'octokit/octokit.rb', require: false
gem 'sidekiq'

gem 'sass-rails',   '~> 4.0.1'
gem 'compass-rails'
gem 'uglifier',     '~> 2.2'
gem 'jquery-rails'

group :doc do
  gem 'yard', require: false
end

group :development do
  gem 'license_finder'
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
  gem 'mail_view'
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'byebug'
  gem 'launchy'
  gem 'rubocop'
end
