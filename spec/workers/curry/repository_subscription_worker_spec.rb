require 'spec_helper'
require 'vcr_helper'

describe Curry::RepositorySubscriptionWorker do
  let(:number_of_pull_requests_in_the_cassette) { 8 }

  before do
    Curry::ImportPullRequestCommitAuthorsWorker.jobs.clear
  end

  it 'creates pull request records for each open pull request' do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')

    VCR.use_cassette('curry_repository_subscription', record: :once) do
      Curry::RepositorySubscriptionWorker.new.perform(repository.id)
    end

    expect(repository.pull_requests.count).to eql(number_of_pull_requests_in_the_cassette)
  end

  it "starts a job to import each pull request's commit authors" do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')

    VCR.use_cassette('curry_repository_subscription', record: :once) do
      Curry::RepositorySubscriptionWorker.new.perform(repository.id)
    end

    expect(Curry::ImportPullRequestCommitAuthorsWorker.jobs.size).to eql(number_of_pull_requests_in_the_cassette)
  end
end
