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
        foodcritic_feedback: format_feedback(feedback,status),
        foodcritic_failure: status
      )
      cookbook.cleanup
    end
  end

  private

  def foodcritic_info
    "Run with Foodcritic Version #{FoodCritic::VERSION} with tags #{ENV['FIERI_FOODCRITIC_TAGS'].to_s}"
  end

  def format_feedback(feedback,status)
    if !status.nil?
      "#{feedback}\n#{foodcritic_info}"
    else
      foodcritic_info
    end
  end
end
