# Rake tasks for running on CI (optimized for Travis)
namespace :spec do
  namespace :ci do
    task :config do
      # config/database.yml
      File.open(Rails.root.join('config', 'database.yml'), 'w') do |f|
        f.write [
          'test:',
          '  adapter:  postgresql',
          '  database: supermarket_test',
          '  username: postgres',
        ].join("\n")
      end

      # config/database.yml
      File.open(Rails.root.join('config', 'application.yml'), 'w') do |f|
        f.write [
          'test:',
          '  icla_version: "99999-2621/LEGAL14767024.1"',
          '  omni_auth:',
          '    github:',
          '      key: TEST_KEY',
          '      secret: TEST_SECRET',
        ].join("\n")
      end

      File.open(Rails.root.join('.rspec'), 'w') do |f|
        f.write [
          '--color',
          '--format progress'
        ].join("\n")
      end
    end
  end
end

desc 'Run tests on CI (Travis)'
task 'spec:ci' => [
  'spec:ci:config',
  'spec',
  'spec:javascripts',
]
