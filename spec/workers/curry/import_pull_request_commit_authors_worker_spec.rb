require 'spec_helper'

describe Curry::ImportPullRequestCommitAuthorsWorker do
  before do
    allow(Curry::ClaValidationWorker).to receive(:perform_async)
    allow_any_instance_of(Curry::ImportPullRequestCommitAuthors).
      to receive(:import_commit_authors)
  end

  let(:pull_request) { create(:pull_request) }

  it 'imports commit authors from the given Pull Request' do
    expect_any_instance_of(Curry::ImportPullRequestCommitAuthors).
      to receive(:import_commit_authors)

    worker = Curry::ImportPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

  it 'runs the ClaValidationWorker' do
    expect(Curry::ClaValidationWorker).
      to receive(:perform_async).
      with(pull_request.id)

    worker = Curry::ImportPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

  it 'does not run the CLA Validation Worker if the pull request does not exist' do
    expect(Curry::ClaValidationWorker).to_not receive(:peform_async)

    worker = Curry::ImportPullRequestCommitAuthorsWorker.new
    worker.perform(nil)
  end

  it "does not run the CLA Validation Worker if the pull request's repository no longer exists" do
    expect(Curry::ClaValidationWorker).to_not receive(:peform_async)

    worker = Curry::ImportPullRequestCommitAuthorsWorker.new
    pull_request = create(:pull_request)
    pull_request.repository.delete
    worker.perform(pull_request.id)
  end
end
