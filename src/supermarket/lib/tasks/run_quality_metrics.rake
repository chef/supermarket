namespace :quality_metrics do
  namespace :run do
    desc "Run quality metrics on latest version of all cookbooks"
    task all_the_latest: :environment do
      result, message = RunQualityMetrics.all_the_latest
      puts "#{result.to_s.upcase}: #{message}"
    end

    desc "Run quality metrics on latest version of a named cookbook"
    task :on_latest, [:cookbook_name] => :environment do |t, args|
      args.with_defaults(cookbook_name: nil)
      unless args[:cookbook_name]
        puts "ERROR: Nothing to do without a cookbook name. e.g. #{t}[cookbook_name]"
        exit 1
      end

      result, message = RunQualityMetrics.on_latest args[:cookbook_name]
      puts "#{result.to_s.upcase}: #{message}"
    end

    desc "Run quality metrics on given version of a named cookbook"
    task :on_version, [:cookbook_name, :version] => :environment do |t, args|
      args.with_defaults(cookbook_name: nil, version: nil)
      unless args[:cookbook_name] && args[:version]
        puts "ERROR: Nothing to do without a cookbook name and version. e.g. #{t}[cookbook_name, version]"
        exit 1
      end

      result, message = RunQualityMetrics.on_version args[:cookbook_name], args[:version]
      puts "#{result.to_s.upcase}: #{message}"
    end
  end
end
