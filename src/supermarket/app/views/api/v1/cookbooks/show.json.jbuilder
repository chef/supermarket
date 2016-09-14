json.partial! 'cookbook', cookbook: @cookbook
json.deprecated @cookbook.deprecated
if @cookbook.deprecated? && @cookbook.replacement.present?
  json.replacement api_v1_cookbook_url(@cookbook.replacement)
end
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
  json.collaborators @cookbook.collaborators.size
end
