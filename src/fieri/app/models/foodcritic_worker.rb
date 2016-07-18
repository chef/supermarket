require 'sidekiq'
require 'net/http'

class FoodcriticWorker
  include ::Sidekiq::Worker

  def perform(params)
    cookbook = CookbookArtifact.new(params['cookbook_artifact_url'], jid)
    feedback, status = cookbook.criticize
    make_post(params, feedback, status)
    cookbook.cleanup
  rescue => e
    log_error(e)
  end

  def log_error(e)
    logger.error e
  end

  def make_post(params, feedback, status)
    response = Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/foodcritic_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['cookbook_name'],
      cookbook_version: params['cookbook_version'],
      foodcritic_feedback: feedback,
      foodcritic_failure: status
    )
    unless response.is_a? Net::HTTPSuccess
      error_msg = "Unable to POST Foodcritic Evaluation of #{params[cookbook_name]} " + response.message
      raise error_msg
    end
  end
end
