namespace :spec do
  task :rubocop do
    fail unless system 'bundle exec rubocop'
  end

  desc 'Run RSpec tests and rubocop'
  task all: [:spec, :javascripts, :rubocop]
end
