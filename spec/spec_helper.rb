# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

# Load factories from FactoryGirl
FactoryGirl.find_definitions

RSpec.configure do |config|
  # Include FactoryGirl mixin for syntax
  config.include FactoryGirl::Syntax::Methods

  # Custom helper modules and extensions
  config.include RequestHelpers

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Reset OmniAuth GitHub stub before each example
  config.before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: 'github',
      uid: '12345',
      info: {
        nickname: 'johndoe',
        email: 'johndoe@example.com',
        name: 'John Doe',
        image: 'https://image-url.com',
      },
      credentials: {
        token: 'oauth_token',
        expires: false
      }
    })
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
  config.order = "random"
end
