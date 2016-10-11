json.license cookbook_version.license
json.tarball_file_size cookbook_version.tarball_file_size
json.version cookbook_version.version
json.average_rating nil
json.cookbook api_v1_cookbook_url(cookbook)
json.file api_v1_cookbook_version_download_url(cookbook_version.cookbook, cookbook_version)
if !@cookbook_version_metrics.nil? && @cookbook_version_metrics.any?
  json.quality do
    @cookbook_version_metrics.each do |metric|
      json.name metric.quality_metric.name
        json.failed metric.failure
        json.feedback metric.feedback
      end
    end
  end
  json.set! :dependencies do
    cookbook_version.cookbook_dependencies.each do |dependency|
    json.set! dependency.name, dependency.version_constraint
  end
end
