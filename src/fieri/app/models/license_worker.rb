require 'sidekiq'
require 'net/http'

class LicenseWorker
  include ::Sidekiq::Worker

  # Acceptable licenses were determined and documented in
  # https://github.com/chef-cookbooks/cookbook-quality-metrics/blob/master/quality-metrics/qm-003-license.md
  ACCEPTABLE_LICENSES = ['Apache 2.0', 'MIT', 'GNU Public License 2.0', 'GNU Public License 3.0'].freeze

  def perform(version_json, cookbook_name)
    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: JSON.parse(version_json)['version'],
      license_failure: license_failure?(version_json),
      license_feedback: license_feedback(cookbook_name, license_failure?(version_json))
    )
  end

  private

  def license_failure?(version_json)
    license = JSON.parse(version_json)['license']

    ACCEPTABLE_LICENSES.include?(license) ? false : true
  end

  def license_feedback(cookbook_name, failure)
    failure == true ? "#{cookbook_name} needs a valid open source license" : ''
  end

  def acceptable_licenses_string
    licenses = 'Acceptable licenses include '

    ACCEPTABLE_LICENSES.each do |license|
      licenses << "#{license}, "
    end

    licenses.gsub(/,\s$/, '')
  end
end
