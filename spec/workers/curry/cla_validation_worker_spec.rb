require 'spec_helper'

describe Curry::ClaValidationWorker do

  context 'when processing a pull pequest' do

    it "annotates the pull request when the PR exists" do
      repository = create(:repository)
      pull_request = repository.pull_requests.create!(number: '1')

      expect_any_instance_of(Curry::PullRequestAnnotator).to receive(:annotate)

      worker = Curry::ClaValidationWorker.new
      worker.perform(pull_request.id)
    end

    it "does not annotate the pull request if the pull request no longer exists" do
      expect_any_instance_of(Curry::PullRequestAnnotator).
        to_not receive(:annotate)

      worker = Curry::ClaValidationWorker.new
      worker.perform(nil)
    end

    it "does not annotate the pull request if the pull request's repository no longer exists" do
      expect_any_instance_of(Curry::PullRequestAnnotator).
        to_not receive(:annotate)

      worker = Curry::ClaValidationWorker.new
      pull_request = create(:pull_request)
      pull_request.repository.delete
      worker.perform(pull_request.id)
    end

  end

end
