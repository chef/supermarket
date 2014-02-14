require 'spec_helper'

describe Curry::PullRequestAppraiserWorker do

  context 'when a CLA is signed' do

    it 'validates each pull request associated with the given user' do
      repository = create(:repository)
      pull_request = create(:pull_request, repository: repository)
      unknown_commit_author = create(:commit_author, login: 'renandstimpy')
      Curry::PullRequestCommitAuthor.create(
        pull_request: pull_request,
        commit_author: unknown_commit_author
      )

      user = create(:user)
      create(:account, user: user, username: 'renandstimpy')

      expect(Curry::ClaValidationWorker).
        to receive(:perform_async).
        with(pull_request.id)

      worker = Curry::PullRequestAppraiserWorker.new
      worker.perform(user.id)
    end

    it 'does not validate the same pull request twice' do
      repository = create(:repository)
      pull_request = create(:pull_request, repository: repository)
      unknown_commit_author = create(:commit_author, login: 'joedoe_work')
      Curry::PullRequestCommitAuthor.create(
        pull_request: pull_request,
        commit_author: unknown_commit_author
      )

      unknown_commit_author_two = create(:commit_author, login: 'joedoe')
      Curry::PullRequestCommitAuthor.create(
        pull_request: pull_request,
        commit_author: unknown_commit_author
      )

      user = create(:user)
      create(:account, user: user, username: 'joedoe')
      create(:account, user: user, username: 'joedoe_work')

      expect(Curry::ClaValidationWorker).
        to receive(:perform_async).
        with(pull_request.id).
        exactly(:once)

      worker = Curry::PullRequestAppraiserWorker.new
      worker.perform(user.id)
    end

  end

end
