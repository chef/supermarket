require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators > 1 ? true : false
  end

  def get_json(cookbook_name)
    uri = URI("https://supermarket.chef.io/api/v1/cookbooks/#{cookbook_name}")
    response = Net::HTTP.get(uri)
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

  def perform(params)
    Net::HTTP.post_form(
      URI.parse('http://supermarket.getchef.com/api/v1/cookbook-versions/evaluation'),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: params['cookbook_name'],
      collaborator_feedback: evaluate(params['cookbook_name'])
      # collaborator_failure: status
    )
  end
end
