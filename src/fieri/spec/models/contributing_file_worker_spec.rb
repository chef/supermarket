require 'rails_helper'

describe ContributingFileWorker do
  let(:cfw) { ContributingFileWorker.new }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributing_file_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  context 'when a source url is present' do
    let(:cookbook_json_response) { File.read('spec/support/cookbook_source_url_fixture.json') }
    let(:github_file_present_response) { File.read('spec/support/github_contributing_file_positive.json') }
    let(:octokit) { Octokit::Client.new(access_token: ENV['FIERI_SUPERMARKET_ENDPOINT']) }

    before do
      allow(Octokit::Client).to receive(:new).and_return(octokit)
    end

    it 'calls the Octokit API wrapper' do
      allow(octokit).to receive(:contents).and_return(github_file_present_response)
      expect(Octokit::Client).to receive(:new).with(access_token: ENV['GITHUB_ACCESS_TOKEN']).and_return(octokit)

      cfw.perform(cookbook_json_response)
    end

    context 'when a source url is valid' do
      # to be valid, must be a github url

      it 'checks the contents of the repo for a CONTRIBUTING.md file' do
        expect(octokit).to receive(:contents).with('johndoe/example_repo', path: 'CONTRIBUTING.md').and_return(github_file_present_response)
        cfw.perform(cookbook_json_response)
      end

      context 'and a CONTRIBUTING.md file is present' do
        before do
          allow(octokit).to receive(:contents).and_return(github_file_present_response)
        end
        it 'posts a passing metric' do
          cfw.perform(cookbook_json_response)

          assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributing_file_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
            expect(req.body).to include('contributing_file_failure=false')
            expect(req.body).to include('contributing_file_feedback=passed')
          end
        end
      end

      context 'and a CONTRIBUTING.md file is not present' do
        # The Github API returns a 404 when a file is not present
        before do
          allow(octokit).to receive(:contents).and_raise(Octokit::NotFound)
        end

        it 'posts a failing metric' do
          cfw.perform(cookbook_json_response)

          assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributing_file_evaluation", times: 1) do |req|
            expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
            expect(req.body).to include('contributing_file_failure=true')
            expect(req.body).to include('contributing_file_feedback=Failure')
          end
        end
      end
    end

    context 'when a source url is not valid' do
      let(:invalid_source_url_json_response) { File.read('spec/support/cookbook_null_source_url_fixture.json') }

      it 'does not attempt to contact the Github API' do
        expect(Octokit::Client).to_not receive(:new)
        cfw.perform(invalid_source_url_json_response)
      end

      it 'posts a failing metric' do
        cfw.perform(invalid_source_url_json_response)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributing_file_evaluation", times: 1) do |req|
          expect(req.body).to include("cookbook_name=#{JSON.parse(cookbook_json_response)['name']}")
          expect(req.body).to include('contributing_file_failure=true')
          expect(req.body).to include('contributing_file_feedback=Failure')
        end
      end
    end
  end
end
