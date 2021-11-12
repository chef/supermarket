namespace :update_spdx_license do
  namespace :run do
    desc "update spdx license for all the cookbook in system"
    task all_cookbooks: :environment do
      result, message = UpdateSpdxLicenseUrl.all_latest_cookbook_versions
      puts "#{result.to_s.upcase}: #{message}"
    end

    desc "update spdx license url for given version of a named cookbook"
    task :on_version, [:cookbook_name, :version] => :environment do |t, args|
      args.with_defaults(cookbook_name: nil, version: nil)
      unless args[:cookbook_name] && args[:version]
        puts "ERROR: Nothing to do without a cookbook name and version. e.g. #{t}[cookbook_name,version]"
        exit 1
      end

      result, message = UpdateSpdxLicenseUrl.on_version( args[:cookbook_name], args[:version] )
      puts "#{result.to_s.upcase}: #{message}"
    end

    desc "update spdx license url for latest version of a named cookbook"
    task :on_latest, [:cookbook_name] => :environment do |t, args|
      args.with_defaults(cookbook_name: nil)
      unless args[:cookbook_name]
        puts "ERROR: Nothing to do without a cookbook name. e.g. #{t}[cookbook_name]"
        exit 1
      end

      result, message = UpdateSpdxLicenseUrl.on_latest(args[:cookbook_name])
      puts "#{result.to_s.upcase}: #{message}"
    end
  end
end
