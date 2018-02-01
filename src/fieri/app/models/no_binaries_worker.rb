require 'sidekiq'
require 'net/http'

class NoBinariesWorker
  include ::Sidekiq::Worker

  def perform(params)
    cookbook = CookbookArtifact.new(params['artifact_url'], jid)
    binary_files = cookbook.binaries

    failure = !binary_files.empty?
    feedback = if failure
                 I18n.t('quality_metrics.no_binaries.failure') + "\n" + binary_files
               else
                 I18n.t('quality_metrics.no_binaries.success')
               end

    make_post(params, feedback, failure)
    cookbook.cleanup
  rescue StandardError => e
    log_error(e)
  end

  def log_error(e)
    logger.error e
  end

  def make_post(params, feedback, failure)
    response = Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/no_binaries_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['name'],
      cookbook_version: params['version'],
      no_binaries_feedback: feedback,
      no_binaries_failure: failure
    )
    return if response.is_a? Net::HTTPSuccess
    raise "Unable to POST No Binaries Evaluation of #{params['name']} " + response.message
  end
end
