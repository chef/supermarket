require 'spec_helper'

describe Curry::PullRequestAppraiserWorker do

  context 'when a CLA is signed' do

    it 'validates each pull request associated with the given user' do
      repository = create(:repository)
      pull_request = create(:pull_request, repository: repository)
      unknown_committer = create(:unknown_committer, login: 'renandstimpy')
      Curry::UnknownPullRequestCommitter.create(
        pull_request: pull_request,
        unknown_committer: unknown_committer
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
      unknown_committer = create(:unknown_committer, login: 'joedoe_work')
      Curry::UnknownPullRequestCommitter.create(
        pull_request: pull_request,
        unknown_committer: unknown_committer
      )

      unknown_committer_two = create(:unknown_committer, login: 'joedoe')
      Curry::UnknownPullRequestCommitter.create(
        pull_request: pull_request,
        unknown_committer: unknown_committer_two
      )

      user = create(:user)
      create(:account, user: user, username: 'joedoe')
      create(:account, user: user, username: 'joedoe_work')

      expect(Curry::ClaValidationWorker).
        to receive(:perform_async).
        with(pull_request.id).
        at_most(:once)

      worker = Curry::PullRequestAppraiserWorker.new
      worker.perform(user.id)
    end

  end

end
