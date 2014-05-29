json.partial! 'cookbook'
json.deprecated @cookbook.deprecated
json.versions Array(@cookbook_versions_urls)
json.metrics do
  json.downloads do
    json.total @cookbook.download_count
    json.set! :versions do
      @cookbook.cookbook_versions.each do |version|
        json.set! version.version, version.download_count
      end
    end
  end
  json.followers @cookbook.followers.size
end
