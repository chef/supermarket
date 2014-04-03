namespace :spec do
  namespace :all do
    task :run do
      system "bundle exec rspec"
      system "bundle exec rake spec:javascripts"
      system "bundle exec rubocop"
    end
  end
end

desc 'Run all the specs'
task 'spec:all' => 'spec:all:run'

task default: 'spec:all'
