require 'sidekiq'
require 'net/http'
require 'octokit'

class ContributorFileWorker
  include ::Sidekiq::Worker

  def perform(cookbook_json)
    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributor_file_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name(cookbook_json),
      contributor_file_failure: evaluate(cookbook_json),
      contributor_file_feedback: give_feedback(cookbook_json)
    )
  end

  private

  def cookbook_name(cookbook_json)
    JSON.parse(cookbook_json)['name']
  end

  def evaluate(cookbook_json)
    octokit_client
  end

  def give_feedback(cookbook_json)
    'passed'
  end

  def octokit_client
    Octokit::Client.new(
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    )
  end
end
