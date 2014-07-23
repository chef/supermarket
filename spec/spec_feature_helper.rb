# Spec helper specifically for Capybara features
require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :quiet_ghost do |app|
  error_logger = Logger.new(STDERR).tap { |l| l.level = Logger::ERROR }

  Capybara::Poltergeist::Driver.new(
    app,
    phantomjs_logger: error_logger,
    timeout: 90
  )
end

Capybara.javascript_driver = :quiet_ghost

# Use JS driver for all features
RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:type] == :feature && example.metadata[:use_poltergeist] == true
      Capybara.current_driver = :quiet_ghost
    else
      Capybara.use_default_driver # presumed to be :rack_test
    end
  end

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FeatureHelpers
end
