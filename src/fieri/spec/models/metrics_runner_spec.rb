require 'rails_helper'

describe MetricsRunner do
  let(:params) do
    {
      'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
      'cookbook_name' => 'apache2',
      'cookbook_version' => '1.2.0'
    }
  end

  let(:cookbook_json_response) { File.read('spec/support/cookbook_metrics_fixture.json') }
  let(:version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }

  let(:metrics_runner) { MetricsRunner.new }
  let(:supermarket_api_runner) { SupermarketApiRunner.new }

  before do
    allow(SupermarketApiRunner).to receive(:new).and_return(supermarket_api_runner)
    allow(supermarket_api_runner).to receive(:cookbook_api_response).and_return(cookbook_json_response)
    allow(supermarket_api_runner).to receive(:cookbook_version_api_response).and_return(version_json_response)
  end

  describe 'getting the information from supermarket' do
    it 'calls the cookbook_api_response method' do
      expect_any_instance_of(SupermarketApiRunner).to receive(:cookbook_api_response).with(params['cookbook_name']).and_return(cookbook_json_response).once
      metrics_runner.perform(params)
    end

    it 'calls the cookbook_version_api_response method' do
      expect_any_instance_of(SupermarketApiRunner).to receive(:cookbook_version_api_response).with(params['cookbook_name'], params['cookbook_version']).and_return(cookbook_json_response).once
      metrics_runner.perform(params)
    end
  end

  describe 'calling individual metrics' do
    it 'calls the collaborator worker' do
      expect(CollaboratorWorker).to receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])

      metrics_runner.perform(params)
    end

    it 'calls the foodcritic worker' do
      expect(FoodcriticWorker).to receive(:perform_async).with(hash_including(params))

      metrics_runner.perform(params)
    end

    it 'calls the publish worker' do
      expect(PublishWorker).to receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])

      metrics_runner.perform(params)
    end

    it 'calls the license worker' do
      expect(LicenseWorker).to receive(:perform_async).with(version_json_response, params['cookbook_name'])

      metrics_runner.perform(params)
    end

    context 'when not in airgapped environments' do
      before do
        expect(ENV['AIR_GAPPED']).to_not eq('true')
      end

      it 'calls the contributing file worker' do
        expect(ContributingFileWorker).to receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])
        metrics_runner.perform(params)
      end

      it 'calls the testing file worker' do
        expect(TestingFileWorker).to receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])
        metrics_runner.perform(params)
      end

      it 'calls the version tag worker' do
        expect(VersionTagWorker).to receive(:perform_async).with(cookbook_json_response, params['cookbook_name'], params['cookbook_version'])
        metrics_runner.perform(params)
      end
    end

    context 'when in airgapped environments' do
      before do
        allow(ENV).to receive(:[]).with('AIR_GAPPED').and_return('true')
      end

      it 'does not call the contributing file worker' do
        expect(ContributingFileWorker).to_not receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])
        metrics_runner.perform(params)
      end

      it 'does not call the testing file worker' do
        expect(TestingFileWorker).to_not receive(:perform_async).with(cookbook_json_response, params['cookbook_name'])
        metrics_runner.perform(params)
      end

      it 'does not call the version tag worker' do
        expect(VersionTagWorker).to_not receive(:perform_async).with(cookbook_json_response, params['cookbook_name'], params['cookbook_version'])
        metrics_runner.perform(params)
      end
    end
  end
end
