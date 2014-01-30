require 'spec_helper'

describe Curry::ImportUnknownPullRequestCommittersWorker do

  it 'imports committers from the given Pull Request' do
    allow(Curry::ClaValidationWorker).to receive(:perform_async)

    pull_request = create(:pull_request)
    expect_any_instance_of(Curry::ImportUnknownPullRequestCommitters).
      to receive(:import)

    worker = Curry::ImportUnknownPullRequestCommittersWorker.new
    worker.perform(pull_request.id)
  end

  it 'runs the ClaValidationWorker' do
    pull_request = create(:pull_request)
    expect(Curry::ClaValidationWorker).
      to receive(:perform_async)

    worker = Curry::ImportUnknownPullRequestCommittersWorker.new
    worker.perform(pull_request.id)
  end

end
