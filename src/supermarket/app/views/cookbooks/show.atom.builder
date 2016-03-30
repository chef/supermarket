atom_feed language: 'en-US' do |feed|
  feed.title "#{@cookbook.name} versions"
  feed.updated @cookbook_versions.max_by(&:updated_at).updated_at

  @cookbook_versions.each do |v|
    feed.entry(v, url: cookbook_version_url(@cookbook, v)) do |entry|
      entry.title "#{v.cookbook.name} - v#{v.version}"
      entry.content cookbook_atom_content(v), type: 'html'
      entry.author do |author|
        author.name v.cookbook.maintainer
        author.uri user_url(v.cookbook.owner)
      end
    end
  end
end
