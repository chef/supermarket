json.name cookbook.name
json.maintainer cookbook.maintainer
json.description cookbook.description
json.category cookbook.category.try(:name)
json.latest_version latest_cookbook_version_url(cookbook)
json.external_url cookbook.source_url # this should be deprecated and removed at some point
json.source_url cookbook.source_url
json.issues_url cookbook.issues_url
json.average_rating nil
json.created_at cookbook.created_at
json.updated_at cookbook.updated_at
json.up_for_adoption cookbook.up_for_adoption
json.partner_status cookbook.partner_cookbooks
