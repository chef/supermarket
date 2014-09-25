atom_feed language: 'en-US' do |feed|
  feed.title "#{@cookbook.name} versions"
  feed.updated @cookbook_versions.max_by(&:updated_at).updated_at

  @cookbook_versions.each do |v|
    feed.entry(v, url: cookbook_version_url(@cookbook, v)) do |entry|
      content = if v.changelog.present?
                  <<-EOS
                    <p>#{v.description}</p>
                    #{HTML_Truncator.truncate(render_document(v.changelog, v.changelog_extension), 30, ellipsis: '')}
                    <p>#{link_to 'View Full Changelog', cookbook_version_url(@cookbook, v, anchor: 'changelog')}</p>
                  EOS
                else
                  v.description
                end

      entry.title "#{v.cookbook.name} - v#{v.version}"
      entry.content content, type: 'html'
      entry.author do |author|
        author.name v.cookbook.maintainer
        author.uri user_url(v.cookbook.owner)
      end
    end
  end
end
