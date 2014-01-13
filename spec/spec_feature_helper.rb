# Spec helper specifically for Capybara features
require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

# Use JS driver for all features
RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:type] == :feature
      Capybara.current_driver = :poltergeist
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
