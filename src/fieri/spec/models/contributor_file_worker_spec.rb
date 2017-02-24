require 'rails_helper'

describe ContributorFileWorker do
  let(:cfw) { ContributorFileWorker.new }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributor_file_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  context 'when a source url is present' do
    let(:cookbook_json_response) { File.read('spec/support/cookbook_sufficient_collaborators_fixture.json') }
    let(:octokit) { Octokit::Client.new(access_token: ENV['FIERI_SUPERMARKET_ENDPOINT']) }



    it 'calls the Octokit API wrapper' do
      expect(Octokit::Client).to receive(:new).with({:access_token=>ENV['GITHUB_ACCESS_TOKEN']}).and_return(octokit)

      cfw.perform(cookbook_json_response)
    end

    context 'when a source url is valid' do
      context 'and a CONTRIBUTING.md file is present' do
        it 'posts a passing metric' do
          cfw.perform(cookbook_json_response)

          assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributor_file_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
            expect(req.body).to include('contributor_file_failure=false')
            expect(req.body).to include('contributor_file_feedback=passed')
          end
        end
      end

      context 'and a CONTRIBUTING.md file is not present' do
        it 'posts a failing metric' do
          cfw.perform(cookbook_json_response)

          assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributor_file_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
            expect(req.body).to include('contributor_file_failure=true')
#            expect(req.body).to include('contributor_file_feedback=Failure')
          end
        end
      end
    end

    context 'when a source url is not valid' do

    end
  end

  context 'when a source url is not present' do

  end

end
