atom_feed language: 'en-US' do |feed|
  feed.title "#{@user.username}'s Followed Cookbook Activity"
  feed.updated safe_updated_at(@followed_cookbook_activity)

  @followed_cookbook_activity.each do |cookbook_version|
    feed.entry cookbook_version, url: cookbook_version_url(cookbook_version.cookbook, cookbook_version.version) do |entry|
      entry.title t('cookbook.activity',
                    maintainer: cookbook_version.user,
                    version: cookbook_version.version,
                    cookbook: cookbook_version.cookbook.name
                   )
      entry.content cookbook_atom_content(cookbook_version), type: 'html'

      entry.author do |author|
        author.name cookbook_version.user
        author.uri user_url(cookbook_version.user)
      end
    end
  end
end
