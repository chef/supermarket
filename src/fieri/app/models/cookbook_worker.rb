require 'sidekiq'
require 'net/http'

class CookbookWorker
  include ::Sidekiq::Worker

  def perform(params)
    begin
      cookbook = CookbookArtifact.new(params['cookbook_artifact_url'], jid)
    rescue Zlib::GzipFile::Error => e
      format_log_message(e)
    end
    feedback, status = cookbook.criticize

    begin
      make_post(params, feedback, status)
    rescue
      format_log_message(e)
    end
    cookbook.cleanup
  end

  def format_log_message(e)
    logger = Logger.new File.new(File.expand_path(ENV['FIERI_LOG_PATH']))
    logger.error e
  end

  def make_post(params, feedback, status)
    Net::HTTP.post_form(
      URI.parse(ENV['FIERI_RESULTS_ENDPOINT']),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['cookbook_name'],
      cookbook_version: params['cookbook_version'],
      foodcritic_feedback: feedback,
      foodcritic_failure: status
    )
  end
end
