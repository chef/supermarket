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
end
