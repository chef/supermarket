require 'rails_helper'

module Fieri
  RSpec.describe JobsController, type: :controller do
    routes { Fieri::Engine.routes }

    describe '#create' do
      let(:params) do
        {
          'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
          'cookbook_name' => 'apache2',
          'cookbook_version' => '1.2.0'
        }
      end

      let(:version_uri) { "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{params['cookbook_name']}/versions/#{params['cookbook_version']}" }
      let(:version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }

      before do
        stub_request(:get, version_uri).
          to_return(status: 200, body: version_json_response, headers: {})
      end

      it 'calls the collaborator worker' do
        expect(CollaboratorWorker).to receive(:perform_async).with(params['cookbook_name'])

        post :create, params
      end

      it 'calls the foodcritic worker' do
        expect(FoodcriticWorker).to receive(:perform_async).with(hash_including(params))

        post :create, params
      end

      it 'calls the publish worker' do
        expect(PublishWorker).to receive(:perform_async).with(params['cookbook_name'])
        post :create, params
      end

      context 'getting the cookbook version information' do
        it 'calls the Supermarket API' do
          expect(Net::HTTP).to receive(:get).with(URI(version_uri)).and_return(version_json_response)
          post :create, params
        end
      end

      it 'calls the license worker' do
        expect(LicenseWorker).to receive(:perform_async).with(version_json_response, params['cookbook_name'])
        post :create, params
      end
    end
  end
end
