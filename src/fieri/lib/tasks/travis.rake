namespace :fieri do
  namespace :travis do
    desc "Things to run during Travis's before_script phase"
    task :before_script do
      puts 'Nothing to setup for fieri.'  
    end

    desc "Tests to run during Travis' script phase"
    task script: [:spec, 'spec:rubocop', 'spec:bundle_audit']
  end
end
