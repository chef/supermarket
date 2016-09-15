json.license cookbook_version.license
json.tarball_file_size cookbook_version.tarball_file_size
json.version cookbook_version.version
json.average_rating nil
json.cookbook api_v1_cookbook_url(cookbook)
json.file api_v1_cookbook_version_download_url(cookbook_version.cookbook, cookbook_version)
if cookbook_version.metric_results.any?
  json.quality do
    json.foodcritic do
      json.failed foodcritic_metric_result(cookbook_version).failure
      json.feedback foodcritic_metric_result(cookbook_version).feedback
    end
    json.collaborator do
      json.failed collaborator_num_metric_result(cookbook_version).failure
      json.feedback collaborator_num_metric_result(cookbook_version).feedback
    end
  end
end
json.set! :dependencies do
  cookbook_version.cookbook_dependencies.each do |dependency|
    json.set! dependency.name, dependency.version_constraint
  end
end
