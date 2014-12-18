atom_feed language: 'en-US' do |feed|
  feed.title 'Cookbooks'
  feed.updated @cookbooks.max_by(&:updated_at).updated_at

  @cookbooks.each do |cookbook|
    feed.entry cookbook, url: cookbook_url(cookbook) do |entry|
      entry.title cookbook.name
      entry.content cookbook_atom_content(cookbook.latest_cookbook_version), type: 'html'

      entry.author do |author|
        author.name cookbook.maintainer
        author.uri user_url(cookbook.owner)
      end
    end
  end
end
