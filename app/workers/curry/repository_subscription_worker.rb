require 'octokit'

class Curry::RepositorySubscriptionWorker
  include Sidekiq::Worker

  def perform(repository_id)
    repository = Curry::Repository.find(repository_id)

    client = Octokit::Client.new(
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    )

    repository_pull_requests = client.pull_requests(repository.full_name, state: 'open')

    repository_pull_requests.each do |gh_pull_request|
      pull_request = repository.pull_requests.numbered(gh_pull_request.number).first_or_create!
      Curry::ImportPullRequestCommitAuthorsWorker.perform_async(pull_request.id)
    end
  end
end
