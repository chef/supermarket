# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "paperclip/matchers"
require "sidekiq/testing"
require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist"
require "capybara-screenshot/rspec"
require "factory_bot_rails"
require "phantomjs"
require "simplecov"
SimpleCov.start

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), "support", "**", "*.rb"))].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

# Treat Sidekiq like ActionMailer. In most cases, tests which queue jobs should
# only care that the job was queued, and not care about the result.
Sidekiq::Testing.fake!

# Use a quieter Poltergeist driver
# This eliminates the debug warnings regarding unrecognized viewport
# arguments and the like
Capybara.register_driver :poltergeist do |app|
  error_logger = Logger.new(STDERR).tap { |l| l.level = Logger::ERROR }

  Capybara::Poltergeist::Driver.new(
    app,
    phantomjs_logger: error_logger,
    timeout: 90,
    phantomjs: Phantomjs.path,
    # set to a width larger than the medium range defined in variables.scss
    # so that tests the navmenu appears at the top of the window, otherwise
    # capybara will complain about
    #   Unable to find css "[rel*=thinginthenavmenu]"
    window_size: [1920, 1080]
  )
end

Capybara.javascript_driver = :poltergeist
Capybara::Screenshot.prune_strategy = { keep: 5 }
Capybara.server = :puma, { Silent: true }

if ENV["CAPYBARA_SCREENSHOT_TO_S3"] == "true"
  if ENV["SCREENIE_AWS_ID"].present? && ENV["SCREENIE_AWS_SECRET"].present?
    Capybara::Screenshot.s3_configuration = {
      s3_client_credentials: {
        access_key_id: ENV["SCREENIE_AWS_ID"],
        secret_access_key: ENV["SCREENIE_AWS_SECRET"],
        region: "us-east-1",
      },
      bucket_name: "supermarket-test-screenshots",
    }
  else
    puts "WARN: asked to save screenshots to S3, but SCREENIE_AWS_ID and SCREENIE_AWS_SECRET are not set. Saving screenshots to local filesystem."
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # Include FactoryBot mixin for syntax
  config.include FactoryBot::Syntax::Methods

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

  # Include our FeatureHelpers from support to dry up feature steps
  config.include FeatureHelpers, type: :feature

  # Include Capybara's DSL for feature steps
  config.include Capybara::DSL, type: :feature

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
  if ENV["TRAVIS_SECURE_ENV_VARS"] == "false"
    config.filter_run_excluding uses_secrets: true
  end

  config.before do
    # Clear ActionMailer deliveries before each example
    ActionMailer::Base.deliveries.clear

    OmniAuth.config.test_mode = true

    OmniAuthControl.stub_github!
    OmniAuthControl.stub_chef!

    ENV["FEATURES"].to_s.split(",").each do |feature|
      Feature.activate(feature)
    end
  end

  config.before(:suite) do
    Dir.mkdir("tmp") unless File.exist?("tmp")
    extensions = %w{pg_trgm plpgsql}
    extensions.each do |ext|
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS #{ext}")
    end
  end

  config.use_transactional_fixtures = false

  #=======================OLD Cleaning strategy======================
  # config.before(:suite) do
  #   DatabaseCleaner.clean_with :truncation
  # end

  # config.before(:each) do |example|
  #   Rails.cache.clear
  #   DatabaseCleaner.strategy = if example.metadata[:js] || example.metadata[:type] == :feature
  #                                :truncation
  #                              else
  #                                :transaction
  #                              end
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
  #================================================================
  config.before(:suite) do |example|
    Rails.cache.clear
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:deletion)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(type: :feature) do |example|
    Capybara.current_driver = :poltergeist if example.metadata[:use_poltergeist] == true
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
