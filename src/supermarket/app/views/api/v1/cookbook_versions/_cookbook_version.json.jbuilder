json.license cookbook_version.license
json.tarball_file_size cookbook_version.tarball_file_size
json.version cookbook_version.version
json.published_at cookbook_version.created_at.iso8601
json.average_rating nil
json.cookbook api_v1_cookbook_url(cookbook)
json.file api_v1_cookbook_version_download_url(cookbook_version.cookbook, cookbook_version)

if ROLLOUT.active?(:fieri)
  json.quality_metrics @cookbook_version_metrics do |metric|
    json.name metric.quality_metric.name
    json.failed metric.failure
    json.feedback metric.feedback
  end
end

json.set! :dependencies do
  cookbook_version.cookbook_dependencies.each do |dependency|
    json.set! dependency.name, dependency.version_constraint
  end
end
