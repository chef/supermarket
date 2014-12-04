require 'spec_helper'
require 'vcr_helper'

describe Curry::RepositorySubscriptionWorker do
  let(:cassett_pr_count) { 16 }

  before do
    Curry::ImportPullRequestCommitAuthorsWorker.jobs.clear
  end

  it 'creates pull request records for each open pull request' do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')

    VCR.use_cassette('curry_repository_subscription', record: :once) do
      Curry::RepositorySubscriptionWorker.new.perform(repository.id)
    end

    expect(repository.pull_requests.count).to eql(cassett_pr_count)
  end

  it "starts a job to import each pull request's commit authors" do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')

    VCR.use_cassette('curry_repository_subscription', record: :once) do
      Curry::RepositorySubscriptionWorker.new.perform(repository.id)
    end

    expect(Curry::ImportPullRequestCommitAuthorsWorker.jobs.size).
      to eql(cassett_pr_count)
  end

  it 'paginates pull request listings' do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')

    VCR.use_cassette('curry_repository_subscription_pagination', record: :once) do
      Curry::RepositorySubscriptionWorker.new(per_page: 4).perform(repository.id)
    end

    expect(Curry::ImportPullRequestCommitAuthorsWorker.jobs.size).
      to eql(cassett_pr_count)
  end

  it 'does not add pull requests which are already tracked' do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')
    repository.pull_requests.create!(number: '10')

    expect do
      VCR.use_cassette('curry_repository_subscription', record: :once) do
        Curry::RepositorySubscriptionWorker.new.perform(repository.id)
      end
    end.to change(repository.pull_requests, :count).by(cassett_pr_count - 1)
  end
end
