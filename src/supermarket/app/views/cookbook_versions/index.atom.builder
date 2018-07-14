atom_feed language: 'en-US' do |feed|
  feed.title 'Cookbook Releases'
  feed.updated safe_updated_at(@cookbook_versions)
  feed.link rel_next_prev_link_tags @cookbook_versions

  @cookbook_versions.each do |release|
    feed.entry release,
               url: cookbook_version_url(release.cookbook, release.version),
               published: release.created_at do |entry|
      entry.title "#{release.name} #{release.version}"
      entry.content <<~CONTENT, type: 'html'
        #{release.owner.name}: #{release.name} #{release.version} released by #{release.published_by.name}
        #{cookbook_atom_content(release)}
      CONTENT

      entry.author do |author|
        author.name "#{release.published_by.name} (#{release.published_by.username})"
        author.uri user_url(release.published_by)
      end
    end
  end
end
