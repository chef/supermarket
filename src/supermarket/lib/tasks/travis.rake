namespace :supermarket do
  namespace :travis do
    desc "Things to run during Travis's before_script phase"
    task :before_script do
      fail unless system "psql -c 'create database supermarket_test;' -U postgres"

      Rake::Task['db:schema:load'].invoke
    end

    desc "Tests to run during Travis' script phase"
    task script: [:spec, 'spec:rubocop', 'spec:bundle_audit']
  end
end
