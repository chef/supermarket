atom_feed language: 'en-US' do |feed|
  feed.title 'Tools & Plugins'
  feed.updated Time.current

  @tools.each do |tool|
    feed.entry tool do |entry|
      entry.title tool.name
      entry.content tool.description

      entry.author do |author|
        author.name tool.maintainer
        author.uri user_url(tool.owner)
      end
    end
  end
end
