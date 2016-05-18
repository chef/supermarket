namespace :spec do
  task :rubocop do
    fail unless system 'bundle exec rubocop'
  end

  task :bundle_audit do
    fail unless system 'bundle exec bundle-audit check --update'
  end

  desc 'Run RSpec tests and rubocop'
  task all: [:spec, :rubocop, :bundle_audit]
end
