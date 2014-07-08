require 'octokit'

class Curry::RepositorySubscriptionWorker
  include Sidekiq::Worker

  def initialize(config_options = {})
    @config_options = {
      access_token: ENV['GITHUB_ACCESS_TOKEN'],
      auto_paginate: true,
      per_page: 100
    }.merge(config_options)
  end

  def perform(repository_id)
    repository = Curry::Repository.find(repository_id)

    client = Octokit::Client.new(@config_options)

    repository_pull_requests = client.pull_requests(repository.full_name, state: 'open')

    repository_pull_requests.each do |gh_pull_request|
      pull_request = repository.pull_requests.numbered(gh_pull_request.number).first_or_create!
      Curry::ImportPullRequestCommitAuthorsWorker.perform_async(pull_request.id)
    end
  end
end
