# Rake tasks for JavaScript specs
namespace :spec do
  ROOT = "#{File.dirname(__FILE__)}/../.."
  KARMA_BIN = "#{ROOT}/node_modules/.bin/karma"
  KARMA_COMMAND = "#{KARMA_BIN} start #{ROOT}/spec/javascripts/config/karma.conf.js"

  task :deps do
    system 'npm install' unless File.exists?(KARMA_BIN)
  end

  desc 'Run JavaScript specs'
  task :js => :deps do
    system "#{KARMA_COMMAND} --singleRun=true --reporters=spec"
  end

  namespace :js do
    desc 'Run JavaScript specs continuously'
    task :watch => :deps do
      system KARMA_COMMAND
    end
  end
end
