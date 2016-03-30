require 'spec_helper'

describe Curry::CommitAuthorVerificationWorker do
  it "changes the user's commit author records to have signed a CLA" do
    allow(Curry::PullRequestAppraiserWorker).to receive(:perform_async)

    user = create(:user)
    account = create(:account, user: user, provider: 'github', username: 'eviltrout')

    pull_request = create(:pull_request)
    pull_request.commit_authors.create!(login: 'eviltrout', authorized_to_contribute: false)

    expect do
      worker = Curry::CommitAuthorVerificationWorker.new
      worker.perform(user.id)
    end.to change { user.reload.verified_commit_author_identities.count }.by(1)
  end

  it 'kicks off the PullRequestAppraiserWorker' do
    user = create(:user)

    expect(Curry::PullRequestAppraiserWorker).
      to receive(:perform_async).
      with(user.id)

    worker = Curry::CommitAuthorVerificationWorker.new
    worker.perform(user.id)
  end
end
