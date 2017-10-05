require 'sidekiq'
require 'net/http'

class PublishWorker
  include ::Sidekiq::Worker

  def perform(cookbook_json, cookbook_name)
    parsed = JSON.parse(cookbook_json)

    failure = false
    publish_feedback = ''

    unless cookbook_exists?(parsed, cookbook_name)
      failure = true
      publish_feedback += "#{cookbook_name} not found in Supermarket\n"
    end

    unless cookbook_not_deprecated?(parsed)
      failure = true
      publish_feedback += "#{cookbook_name} is deprecated\n"
    end

    unless cookbook_not_for_adoption?(parsed)
      failure = true
      publish_feedback += "#{cookbook_name} is up for adoption\n"
    end

    unless failure
      publish_feedback = "#{cookbook_name} passed the publish metric"
    end

    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      publish_failure: failure,
      publish_feedback: publish_feedback
    )
  end

  private

  def cookbook_exists?(cookbook_output, cookbook_name)
    cookbook_output['name'] == cookbook_name
  end

  def cookbook_not_deprecated?(cookbook_output)
    cookbook_output['deprecated'] != true
  end

  def cookbook_not_for_adoption?(cookbook_output)
    cookbook_output['up_for_adoption'] != true
  end
end
