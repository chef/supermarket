# Rake tasks for JavaScript specs
namespace :spec do
  namespace :javascripts do
    task :deps do
      system "cd #{Rails.root} && npm install" unless File.exist?(karma_bin)
    end

    task run: :deps do
      fail unless system "#{karma_command} --singleRun=true --reporters=dots"
    end

    desc 'Run JavaScript specs continuously'
    task watch: :deps do
      system karma_command
    end

    def karma_bin
      "#{Rails.root}/node_modules/.bin/karma"
    end

    def karma_command
      "#{karma_bin} start #{Rails.root}/spec/javascripts/config/karma.conf.js"
    end
  end
end

desc 'Run javascript specs'
task 'spec:javascripts' => 'spec:javascripts:run'
