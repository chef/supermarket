# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
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

  # ENV-munging helpers
  config.include EnvHelpers

  # Helpers to build in-memory archives
  config.include TarballHelpers

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!

  # Skip specs that require secure environment variables when running them
  # with Travis CI.
  if ENV['TRAVIS_SECURE_ENV_VARS'] == 'false'
    config.filter_run_excluding uses_secrets: true
  end

  config.before do
    # Clear ActionMailer deliveries before each example
    ActionMailer::Base.deliveries.clear

    OmniAuth.config.test_mode = true

    OmniAuthControl.stub_github!
    OmniAuthControl.stub_chef!

    ENV['FEATURES'].to_s.split(',').each do |feature|
      ROLLOUT.activate(feature)
    end
  end

  config.before(:suite) do
    Dir.mkdir('tmp') unless File.exist?('tmp')
    extensions = %w(pg_trgm plpgsql)
    extensions.each do |ext|
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS #{ext}")
    end
  end

  config.before(:each) do
    Rails.cache.clear
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
