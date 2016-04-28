namespace :spec do
  task :rubocop do
    fail unless system 'bundle exec rubocop'
  end

  task :bundle_audit do
    fail unless system 'bundle exec bundle-audit check --update'
  end

  desc 'Tests to run in Travis'
  task travis: [:spec, :rubocop, :bundle_audit]

  desc 'Run RSpec tests and rubocop'
  task all: [:spec, :javascripts, :rubocop, :bundle_audit]
end
