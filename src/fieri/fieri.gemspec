$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'fieri/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'fieri'
  s.version     = Fieri::VERSION
  s.authors     = ['Supermarket Team']
  s.email       = ['supermarket@chef.io']
  s.homepage    = 'https://supermarket.chef.io'
  s.summary     = 'Chef Cookbook Criticizer as a Service'
  s.description = 'Chef Cookbook Criticizer as a Service'
  s.license     = 'Apache 2.0'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.1.14.2'
  s.add_dependency 'sidekiq'
  s.add_dependency 'dotenv-rails'
  s.add_dependency 'foodcritic'
end
