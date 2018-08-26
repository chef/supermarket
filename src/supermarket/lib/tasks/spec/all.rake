namespace :spec do
  task :rubocop do
    fail unless system 'bundle exec rubocop'
  end

  task :bundle_audit do
    fail unless system 'bundle exec bundle-audit check --update --ignore CVE-2018-1000544'
  end

  desc 'Run RSpec tests and rubocop'
  task all: [:spec, :javascripts, :rubocop, :bundle_audit]
end
