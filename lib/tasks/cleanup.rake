namespace :cleanup do
  task :supported_platforms => :environment do
    platforms = SupportedPlatform.all.reduce([]) do |result, platform|
      result << {name: platform.name, version: platform.version_constraint, cookbook_version_id: platform.cookbook_version_id}
    end

    SupportedPlatform.delete_all

    platforms.each do |platform|
      cookbook_version = CookbookVersion.find(platform[:cookbook_version_id])
      supported_platform = SupportedPlatform.for_name_and_version(platform[:name], platform[:version])
      CookbookVersionPlatform.create! supported_platform: supported_platform, cookbook_version: cookbook_version
    end
  end
end
