atom_feed language: 'en-US' do |feed|
  feed.title 'Cookbooks'
  feed.updated Time.now

  @cookbooks.each do |cookbook|
    feed.entry cookbook do |entry|
      entry.title cookbook.name
      entry.maintainer cookbook.maintainer
      entry.description cookbook.description
      entry.url cookbook_url(cookbook)
    end
  end
end
