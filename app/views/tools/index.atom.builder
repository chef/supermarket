atom_feed language: 'en-US' do |feed|
  feed.title 'Tools & Plugins'
  feed.updated Time.now

  @tools.each do |tool|
    feed.entry tool do |entry|
      entry.title tool.name
      entry.maintainer tool.maintainer
      entry.description tool.description
    end
  end
end
