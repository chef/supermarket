json.items @results do |cookbook|
  json.cookbook_name cookbook.name
  json.cookbook_maintainer cookbook.maintainer
  json.cookbook_description cookbook.description
  json.cookbook api_v1_cookbook_url(cookbook)
end
