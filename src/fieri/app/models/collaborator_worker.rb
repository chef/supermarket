require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators > 1 ? true : false
  end

  def get_json(cookbook_name)
    uri = URI.parse("http://localhost:3000/api/v1/cookbooks/#{cookbook_name}")
    response = Net::HTTP.get(uri)
    response
  end

  def get_collaborator_count(json)
    parsed = JSON.parse(json)
    parsed['metrics']['collaborators']
  end

  def evaluate(cookbook_name)
    cookbook_json = get_json(cookbook_name)
    collaborator_count = get_collaborator_count(cookbook_json)
    sufficient_collaborators?(collaborator_count) ? false : true
  end

  def give_feedback(cookbook_name)
    json = get_json(cookbook_name)
    collaborator_count = get_collaborator_count(json)
    if evaluate(cookbook_name)
      I18n.t('quality_metrics.collaborator.failure', :collaborators => collaborator_count.to_s + ' collaborators', :passing_number => '2')
    else
      I18n.t('quality_metrics.collaborator.success', :collaborators => collaborator_count.to_s + ' collaborators')
    end
  end

  def perform(cookbook_name)
    Net::HTTP.post_form(
      URI.parse(ENV['FIERI_COLLABORATORS_ENDPOINT']),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      collaborator_failure: evaluate(cookbook_name),
      collaborator_feedback: give_feedback(cookbook_name)
    )
  end
end