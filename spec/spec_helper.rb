if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!('rails')
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'paperclip/matchers'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

# Load factories from FactoryGirl
FactoryGirl.find_definitions

# Treat Sidekiq like ActionMailer. In most cases, tests which queue jobs should
# only care that the job was queued, and not care about the result.
Sidekiq::Testing.fake!

RSpec.configure do |config|
  # Include FactoryGirl mixin for syntax
  config.include FactoryGirl::Syntax::Methods

  # Include Paperclip matchers
  config.include Paperclip::Shoulda::Matchers

  # Custom helper modules and extensions
  config.include RequestHelpers

  # Helpers that stub sign in and sign out with current_user
  config.include AuthHelpers

  # Request helpers specifically useful for the API
  config.include ApiSpecHelpers, type: :request

  # View helpers
  config.include ViewSpecHelpers, type: :view

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Skip specs that require secure environment variables when running them
  # with Travis CI.
  if ENV['TRAVIS_SECURE_ENV_VARS'] == 'false'
    config.filter_run_excluding uses_secrets: true
  end

  config.before do
    # Clear ActionMailer deliveries before each example
    ActionMailer::Base.deliveries.clear

    # Reset OmniAuth GitHub stub before each example
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '12345',
      info: {
        nickname: 'johndoe',
        email: 'johndoe@example.com',
        name: 'John Doe',
        image: 'https://image-url.com'
      },
      credentials: {
        token: 'oauth_token',
        expires: false
      }
    )

    # Reset OmniAuth Developer stub before each example
    OmniAuth.config.mock_auth[:chef_oauth2] = OmniAuth::AuthHash.new(
      provider: 'chef_oauth2',
      uid: '12345',
      info: {
        username: 'johndoe',
        email: 'johndoe@example.com',
        first_name: 'John',
        last_name: 'Doe',
        public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVuZCyYt/gLXeclgnEibmM0+o1hPNaGGls6/lFNJYa1VvoN7dNdvXIdC6cPcBAijZp/LJI6u2w0dIjo7H2lw8aYF1TgmrYzeuCy+OZjXvfk6ZCi2ls3AILsxfw8S74Gd06JB+nwYJmusF/b01Bn1ua9ywaIUpKf5ewP0aM/2nAcJn/1C+q/JyRSK0DrfajV+Tiw0jufblzx6mfvSMtFUresEAKnsmu1QJYH6aNAvBWIiz/Sh7uIBA5tHHCP43G/95tPP9wXw2Capp/aOX+PViwkGuh8ebJaYjPhV35jGGXFdUPkcHj/i14bxUVKFjUkcLataLW7DvcO4LQfZtRt0p'
      },
      credentials: {
        token: 'oauth_token',
        expires: false
      }
    )
  end

  config.before(:suite) do
    Dir.mkdir('tmp') unless File.exists?('tmp')
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
