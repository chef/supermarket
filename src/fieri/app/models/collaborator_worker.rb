require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators > 1 ? true : false
  end

  def get_json(cookbook_name)
    uri = 'https://supermarket.chef.io/api/v1/cookbooks'
    data = cookbook_name
    response = Net::HTTP.post_form(uri, data)
  end

  def get_collaborator_count(json)
    parsed = JSON.parse(json)
    parsed["metrics"]["collaborators"]
  end

  def perform(params)
  end
end
