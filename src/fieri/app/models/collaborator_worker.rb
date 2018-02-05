require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker
  SUFFICENT_COLLABORATORS = 2

  def perform(cookbook_json, cookbook_name)
    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/collaborators_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      collaborator_failure: evaluate(cookbook_json),
      collaborator_feedback: give_feedback(cookbook_json)
    )
  end

  private

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators >= CollaboratorWorker::SUFFICENT_COLLABORATORS
  end

  def get_collaborator_count(json)
    parsed = JSON.parse(json)
    parsed['metrics']['collaborators']
  end

  def evaluate(cookbook_json)
    collaborator_count = get_collaborator_count(cookbook_json)
    sufficient_collaborators?(collaborator_count) ? false : true
  end

  def give_feedback(cookbook_json)
    collaborator_count = get_collaborator_count(cookbook_json)
    if evaluate(cookbook_json)
      I18n.t(
        'quality_metrics.collaborator.failure',
        num_collaborators: collaborator_count.to_s,
        passing_number: CollaboratorWorker::SUFFICENT_COLLABORATORS.to_s
      )
    else
      I18n.t(
        'quality_metrics.collaborator.success',
        num_collaborators: collaborator_count.to_s
      )
    end
  end
end
