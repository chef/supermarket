require 'sidekiq'
require 'net/http'

class SupportedPlatformsWorker
  include ::Sidekiq::Worker

  attr_accessor :version_info, :cookbook_name

  def perform(version_json, cookbook_name)
    @version_info = JSON.parse(version_json)
    @cookbook_name = cookbook_name

    response = Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/supported_platforms_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: version_info['version'],
      supported_platforms_failure: supported_platforms_failure?,
      supported_platforms_feedback: supported_platforms_feedback
    )

    return if response.is_a? Net::HTTPSuccess
    raise "Unable to POST Supported Platforms Evaluation of #{cookbook_name}: #{response.code} #{response.message}"
  rescue StandardError => e
    log_error(e)
  end

  def supported_platforms_failure?
    !(version_info.key?('supports') && version_info['supports'].length >= 1)
  end

  def supported_platforms_feedback
    if supported_platforms_failure?
      I18n.t(
        'quality_metrics.supported_platforms.failure',
        cookbook_name: cookbook_name
      )
    else
      I18n.t(
        'quality_metrics.supported_platforms.success',
        cookbook_name: cookbook_name
      )
    end
  end

  def log_error(e)
    logger.error e
  end
end
