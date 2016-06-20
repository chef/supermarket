require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators > 1 ? true : false
  end

  def get_json(cookbook_name)
    uri = URI.parse("http://localhost:3000/api/v1/cookbooks/dragons")
    response = Net::HTTP.get(uri)
    return response
  end

  def get_collaborator_count(json)
    parsed = JSON.parse(json)
    parsed["metrics"]["collaborators"]
  end

  def evaluate(cookbook_name)
    cookbook_json = get_json(cookbook_name)
    collaborator_count = get_collaborator_count(cookbook_json)
    sufficient_collaborators?(collaborator_count)
  end

  def give_feedback(cookbook_name)
    evaluate(cookbook_name) ? 'This cookbook has sufficient collaborators.' : 'This cookbook does not have sufficient collaborators.'
  end

  def perform(params)
    # Sidekiq::Logging.logger.info "FIRING COOKBOOKWORKER#perform"
    # Sidekiq::Logging.logger.info params.inspect
    # Sidekiq::Logging.logger.info params['cookbook_name']
    Net::HTTP.post_form(
      URI.parse(ENV['FIERI_RESULTS_ENDPOINT']),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['cookbook_name'],
      collaborator_failure: evaluate(params),
      collaborator_feedback: give_feedback(params['cookbook_name'])
    )
  end
end
