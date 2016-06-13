require 'sidekiq'
require 'net/http'

class CollaboratorWorker
  include ::Sidekiq::Worker

  def sufficient_collaborators?(number_of_collaborators)
    number_of_collaborators > 1 ? true : false
  end

  def get_collaborators(cookbook_name)
    uri = 'https://supermarket.chef.io/api/v1/cookbooks'
    data = cookbook_name
    response = Net::HTTP.post_form(uri, data)
  end

  def perform(params)
    # begin
    #   cookbook = CookbookArtifact.new(params['cookbook_artifact_url'], jid)
    # rescue Zlib::GzipFile::Error => e
    #   logger = Logger.new File.new(File.expand_path('./log/fieri.log'))
    #   logger.error e
    # else
    #   feedback, status = cookbook.criticize

    #   Net::HTTP.post_form(
    #     URI.parse(ENV['FIERI_RESULTS_ENDPOINT']),
    #     fieri_key: ENV['FIERI_KEY'],
    #     cookbook_name: params['cookbook_name'],
    #     cookbook_version: params['cookbook_version'],
    #     collaborator_feedback: feedback,
    #     collaborator_failure: status
    #   )

    #   cookbook.cleanup
    # end
  end
end
