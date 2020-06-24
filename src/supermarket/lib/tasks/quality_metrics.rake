namespace :quality_metrics do
  desc "List the names of quality metrics"
  task list: :environment do
    puts "Quality Metrics:"
    QualityMetric.all.each do |qm|
      puts "+ #{qm.name}"
    end
  end

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

  namespace :flip do
    desc "Flip all quality metrics visible to all users"
    task all_public: :environment do
      QualityMetric.flip_public
      puts "OK: All quality metrics are now visible to all users."
    end

    desc "Flip all quality metrics visible to only admin users"
    task all_admin_only: :environment do
      QualityMetric.flip_admin_only
      puts "OK: All quality metrics are now visible to only admin users."
    end

    desc "Flip a given quality metric visible to all users"
    task :public, [:metric_name] => :environment do |t, args|
      args.with_defaults(metric_name: nil)

      metric_name = args[:metric_name]
      unless metric_name
        puts "ERROR: Nothing to do without a metric name. e.g. #{t}[metric_name]"
        exit 1
      end

      quality_metric = QualityMetric.find_by(name: metric_name)
      unless quality_metric
        puts "ERROR: No quality metric found with the name '#{metric_name}'."
        exit 1
      end

      quality_metric.flip_public
      puts "OK: The #{metric_name} quality metric is now visible to all users."
    end

    desc "Flip a given quality metric visible to only admin users"
    task :admin_only, [:metric_name] => :environment do |t, args|
      args.with_defaults(metric_name: nil)

      metric_name = args[:metric_name]
      unless metric_name
        puts "ERROR: Nothing to do without a metric name. e.g. #{t}[metric_name]"
        exit 1
      end

      quality_metric = QualityMetric.find_by(name: metric_name)
      unless quality_metric
        puts "ERROR: No quality metric found with the name '#{metric_name}'."
        exit 1
      end

      quality_metric.flip_admin_only
      puts "OK: The #{metric_name} quality metric is now visible to only admin users."
    end
  end
end
