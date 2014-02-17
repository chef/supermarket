require 'spec_helper'

describe Curry::ImportUnknownPullRequestCommitAuthorsWorker do

  it 'imports commit authors from the given Pull Request' do
    allow(Curry::ClaValidationWorker).to receive(:perform_async)

    pull_request = create(:pull_request)
    expect_any_instance_of(Curry::ImportUnknownPullRequestCommitAuthors).
      to receive(:import)

    worker = Curry::ImportUnknownPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

  it 'runs the ClaValidationWorker' do
    pull_request = create(:pull_request)
    expect(Curry::ClaValidationWorker).
      to receive(:perform_async)

    worker = Curry::ImportUnknownPullRequestCommitAuthorsWorker.new
    worker.perform(pull_request.id)
  end

end
