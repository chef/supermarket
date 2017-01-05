require 'rails_helper'

describe SupportedPlatformsWorker do
  let(:evaluation_endpoint) do
    "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/supported_platforms_evaluation"
  end
  let(:happy_version_data) { File.read('spec/support/cookbook_version_fixture.json') }
  let(:cookbook_version) { JSON.parse(happy_version_data)['version'] }
  let(:cookbook_name) { 'apt' }

  before do
    stub_request(:post, 'http://localhost:13000/api/v1/quality_metrics/supported_platforms_evaluation').
      to_return(status: 200, body: '', headers: {})
  end

  context 'when the cookbook version has supported platforms' do
    it 'submits positive feedback' do
      subject.perform(happy_version_data, cookbook_name)

      assert_requested(:post, evaluation_endpoint, times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{cookbook_name}")
        expect(req.body).to include("cookbook_version=#{cookbook_version}")
        expect(req.body).to include('supported_platforms_failure=false')
      end
    end
  end

  context 'when the cookbook version does not have supported platforms' do
    let(:no_supports_version_data) { File.read('spec/support/cookbook_version_with_no_supported_platforms.json') }
    let(:cookbook_version) { JSON.parse(no_supports_version_data)['version'] }

    it 'submits room for improvement' do
      subject.perform(no_supports_version_data, cookbook_name)

      assert_requested(:post, evaluation_endpoint, times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{cookbook_name}")
        expect(req.body).to include("cookbook_version=#{cookbook_version}")
        expect(req.body).to include('supported_platforms_failure=true')
      end
    end
  end

  describe 'when posting results back to Supermarket' do
    let(:cookbook_name) { 'not_gonna_work' }

    it 'rescues a POST error' do
      stub_request(:post, evaluation_endpoint).
        with(body: hash_including(cookbook_name: 'not_gonna_work')).
        to_return(status: 502, body: '', headers: {})

      expect(subject).to receive(:log_error)

      subject.perform(happy_version_data, cookbook_name)
    end

    it 'rescues a timeout' do
      stub_request(:post, evaluation_endpoint).
        with(body: hash_including(cookbook_name: 'not_gonna_work')).
        to_timeout

      expect(subject).to receive(:log_error)

      subject.perform(happy_version_data, cookbook_name)
    end
  end
end
