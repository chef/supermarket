require "sidekiq"
require "net/http"

class CookstyleWorker
  include ::Sidekiq::Worker

  def perform(params)
    cookbook = CookbookArtifact.new(params["artifact_url"], jid)
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
      URI.parse("#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/cookstyle_evaluation"),
      fieri_key: ENV["FIERI_KEY"],
      cookbook_name: params["name"],
      cookbook_version: params["version"],
      cookstyle_feedback: format_feedback(feedback, status),
      cookstyle_failure: status
    )
    return if response.is_a? Net::HTTPSuccess

    raise "Unable to POST Cookstyle Evaluation of #{params["name"]} " + response.message
  end

  private

  def cookstyle_info
    "Run with Cookstyle Version #{Cookstyle::VERSION} with cops #{ENV["COOKSTYLE_COPS"]}"
  end

  def format_feedback(feedback, status)
    if !status.nil?
      "#{feedback}\n#{cookstyle_info}"
    else
      cookstyle_info
    end
  end
end
