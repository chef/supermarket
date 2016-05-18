require 'sidekiq'
require 'net/http'

class CookbookWorker
  include ::Sidekiq::Worker

  def perform(params)
    begin
      cookbook = CookbookArtifact.new(params['cookbook_artifact_url'], jid)
    rescue Zlib::GzipFile::Error => e
      logger = Logger.new File.new(File.expand_path('./log/fieri.log'))
      logger.error e
    else
      feedback, status = cookbook.criticize

      Net::HTTP.post_form(
        URI.parse(ENV['RESULTS_ENDPOINT']),
        fieri_key: ENV['AUTH_TOKEN'],
        cookbook_name: params['cookbook_name'],
        cookbook_version: params['cookbook_version'],
        foodcritic_feedback: feedback,
        foodcritic_failure: status
      )

      cookbook.cleanup
    end
  end
end
