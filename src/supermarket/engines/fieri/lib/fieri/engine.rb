require 'dotenv-rails'
Dotenv.load('.env')

module Fieri
  class Engine < ::Rails::Engine
    isolate_namespace Fieri

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
