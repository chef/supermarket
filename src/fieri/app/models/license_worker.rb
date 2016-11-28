require 'sidekiq'
require 'net/http'

class LicenseWorker
  include ::Sidekiq::Worker

  def perform(version_json, cookbook_name)
    failure = false
    license_feedback = ''

    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: JSON.parse(version_json)['version'],
      license_failure: failure,
      license_feedback: license_feedback
    )
  end
end
