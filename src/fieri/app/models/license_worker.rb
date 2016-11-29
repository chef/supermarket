require 'sidekiq'
require 'net/http'

class LicenseWorker
  include ::Sidekiq::Worker

  # Acceptable licenses were determined and documented in
  # https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/master/quality-metrics/qm-003-license.md
  ACCEPTABLE_LICENSES = ['Apache 2.0', 'MIT', 'GNU Public License 2.0', 'GNU Public License 3.0'].freeze

  def perform(version_json, cookbook_name)
    version_info = JSON.parse(version_json)
    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: version_info['version'],
      license_failure: license_failure?(version_info['license']),
      license_feedback: license_feedback(cookbook_name, license_failure?(version_info['license']))
    )
  end

  private

  def license_failure?(license)
    ACCEPTABLE_LICENSES.include?(license) ? false : true
  end

  def license_feedback(cookbook_name, failure)
    if failure
      "#{cookbook_name} does not have a valid open source license.\nAcceptable licenses include #{ACCEPTABLE_LICENSES.join(', ')}."
    else
      "#{cookbook_name} has a recognized open source license."
    end
  end
end
