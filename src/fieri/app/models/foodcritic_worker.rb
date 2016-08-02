require 'sidekiq'
require 'net/http'

class FoodcriticWorker
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
        URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/foodcritic_evaluation"),
        fieri_key: ENV['FIERI_KEY'],
        cookbook_name: params['cookbook_name'],
        cookbook_version: params['cookbook_version'],
        foodcritic_feedback: feedback,
        foodcritic_failure: status,
        foodcritic_version: FoodCritic::VERSION,
        foodcritic_tags: ENV['FIERI_FOODCRITIC_TAGS'].to_s
      )

      cookbook.cleanup
    end
  end

end
