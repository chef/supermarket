require 'sidekiq'
require 'net/http'

class LicenseWorker
  include ::Sidekiq::Worker

  def perform(version_json, cookbook_name)
    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: JSON.parse(version_json)['version'],
      license_failure: license_failure?(version_json),
      license_feedback: license_feedback(cookbook_name)
    )
  end

  private

  def license_failure?(version_json)
    JSON.parse(version_json)['license'].present? ? false : true
  end

  def license_feedback(cookbook_name)
    "#{cookbook_name} has no license"
  end
end
