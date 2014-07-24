atom_feed language: 'en-US' do |feed|
  feed.title "#{@user.username}'s Followed Cookbook Activity"
  feed.updated Time.now

  @followed_cookbook_activity.each do |cookbook_version|
    feed.entry cookbook_version, url: cookbook_version_url(cookbook_version.cookbook, cookbook_version.version) do |entry|
      entry.title cookbook_version.cookbook.name
      entry.maintainer cookbook_version.cookbook.maintainer
      entry.description cookbook_version.description
      entry.version cookbook_version.version
    end
  end
end
