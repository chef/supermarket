require 'rails_helper'

describe CollaboratorWorker do
  let(:cw) { CollaboratorWorker.new }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/collaborators_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  context 'when there is a sufficient number of collaborators' do
    let(:cookbook_json_response) { File.read('spec/support/cookbook_sufficient_collaborators_fixture.json') }

    it 'posts a passing metric' do
      cw.perform(cookbook_json_response)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/collaborators_evaluation", times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
        expect(req.body).to include('collaborator_failure=false')
        expect(req.body).to include('collaborator_feedback=passed')
      end
    end
  end

  context 'when there is not a sufficient number of collaborators' do
    let(:cookbook_json_response) { File.read('spec/support/cookbook_insufficient_collaborators_fixture.json') }

    it 'posts a failing metric' do
      cw.perform(cookbook_json_response)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/collaborators_evaluation", times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
        expect(req.body).to include('collaborator_failure=true')
        expect(req.body).to include('collaborator_feedback=Failure')
      end
    end
  end
end
