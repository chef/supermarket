require 'spec_helper'

describe Curry::ImportUnknownPullRequestCommitAuthorsWorker do

  before do
    allow(Curry::ClaValidationWorker).to receive(:perform_async)
    allow_any_instance_of(Curry::ImportUnknownPullRequestCommitAuthors).
      to receive(:import)
  end

  let(:pull_request) { create(:pull_request) }

  it 'imports commit authors from the given Pull Request' do
    expect_any_instance_of(Curry::ImportUnknownPullRequestCommitAuthors).
      to receive(:import)

    worker = Curry::ImportUnknownPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

  it 'runs the ClaValidationWorker' do
    expect(Curry::ClaValidationWorker).
      to receive(:perform_async).
      with(pull_request.id)

    worker = Curry::ImportUnknownPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

end
