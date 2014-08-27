json.contingents @contingents do |contingent|
  json.name contingent.cookbook_version.cookbook.name
  json.version contingent.cookbook_version.version
  json.url api_v1_cookbook_version_url(
    contingent.cookbook_version.cookbook,
    contingent.cookbook_version
  )
end
