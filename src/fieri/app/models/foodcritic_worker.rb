require 'sidekiq'
require 'net/http'

class FoodcriticWorker
  include ::Sidekiq::Worker

  def perform(params)
    cookbook = CookbookArtifact.new(params['artifact_url'], jid)
    feedback, status = cookbook.criticize
    make_post(params, feedback, status)
    cookbook.cleanup
  rescue StandardError => e
    log_error(e)
  end

  def log_error(e)
    logger.error e
  end

  def make_post(params, feedback, status)
    response = Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/foodcritic_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['name'],
      cookbook_version: params['version'],
      foodcritic_feedback: format_feedback(feedback, status),
      foodcritic_failure: status
    )
    return if response.is_a? Net::HTTPSuccess
    raise "Unable to POST Foodcritic Evaluation of #{params['name']} " + response.message
  end

  private

  def foodcritic_info
    "Run with Foodcritic Version #{FoodCritic::VERSION} with tags #{ENV['FIERI_FOODCRITIC_TAGS']} and failure tags #{ENV['FIERI_FOODCRITIC_FAIL_TAGS']}"
  end

  def format_feedback(feedback, status)
    if !status.nil?
      "#{feedback}\n#{foodcritic_info}"
    else
      foodcritic_info
    end
  end
end
