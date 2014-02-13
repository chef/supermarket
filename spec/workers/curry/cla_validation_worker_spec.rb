require 'spec_helper'

describe Curry::ClaValidationWorker do

  context 'when processing a Pull Request Update' do

    it "annotates the Update's associated Pull Request" do
      repository = create(:repository)
      pull_request = repository.pull_requests.create!(number: '1')

      expect_any_instance_of(Curry::PullRequestAnnotator).to receive(:annotate)

      worker = Curry::ClaValidationWorker.new
      worker.perform(pull_request.id)
    end

  end

end
