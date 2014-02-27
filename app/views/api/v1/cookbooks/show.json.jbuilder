json.name @cookbook.name
json.maintainer @cookbook.maintainer
json.description @cookbook.description
json.category @cookbook.category
json.latest_version api_v1_cookbook_version_url(@cookbook, @cookbook.get_version!('latest'))
json.external_url @cookbook.external_url
json.deprecated @cookbook.deprecated
json.average_rating nil
json.versions @cookbook.cookbook_versions.order('version ASC').map { |version| api_v1_cookbook_version_url(@cookbook, version) }
json.created_at @cookbook.created_at
json.updated_at @cookbook.get_version!('latest').updated_at
