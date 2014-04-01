atom_feed language: 'en-US' do |feed|
  feed.title "#{@cookbook.name} versions"
  feed.updated @cookbook_versions.max_by(&:updated_at).updated_at

  @cookbook_versions.each do |v|
    feed.entry(v, url: cookbook_version_url(@cookbook, v)) do |entry|
      entry.title v.version
      entry.license v.license
    end
  end
end
